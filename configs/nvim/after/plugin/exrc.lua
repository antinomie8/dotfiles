--- Reads trust database from $XDG_STATE_HOME/nvim/trust.
---
---@return table<string, string> Contents of trust database, if it exists. Empty table otherwise.
local function read_trust()
	local trust = {} ---@type table<string, string>
	local f = io.open(vim.fn.stdpath("state") .. "/trust", "r")
	if f then
		local contents = f:read("*a")
		if contents then
			for line in vim.gsplit(contents, "\n") do
				local hash, file = string.match(line, "^(%S+) (.+)$")
				if hash and file then
					trust[file] = hash
				end
			end
		end
		f:close()
	end
	return trust
end

--- If {fullpath} is a file, read the contents of {fullpath} (or the contents of {bufnr}
--- if given) and returns the contents and a hash of the contents.
---
--- If {fullpath} is a directory, then nothing is read from the filesystem, and
--- `contents = true` and `hash = "directory"` is returned instead.
---
---@param fullpath string Path to a file or directory to read.
---@param bufnr integer? The number of the buffer.
---@return string|boolean? contents the contents of the file, or true if it's a directory
---@return string? hash the hash of the contents, or "directory" if it's a directory
local function compute_hash(fullpath, bufnr)
	local contents ---@type string|boolean?
	local hash ---@type string
	if vim.fn.isdirectory(fullpath) == 1 then
		return true, "directory"
	end

	if bufnr then
		local newline = vim.bo[bufnr].fileformat == "unix" and "\n" or "\r\n"
		contents =
		           table.concat(vim.api.nvim_buf_get_lines(bufnr --[[@as integer]], 0, -1, false), newline)
		if vim.bo[bufnr].endofline then
			contents = contents .. newline
		end
	else
		do
			local f = io.open(fullpath, "rb")
			if not f then
				return nil, nil
			end
			contents = f:read("*a")
			f:close()
		end

		if not contents then
			return nil, nil
		end
	end

	hash = vim.fn.sha256(contents)

	return contents, hash
end

--- Writes provided {trust} table to trust database at
--- $XDG_STATE_HOME/nvim/trust.
---
---@param trust table<string, string> Trust table to write
local function write_trust(trust)
	vim.validate("trust", trust, "table")
	local f = assert(io.open(vim.fn.stdpath("state") .. "/trust", "w"))

	local t = {} ---@type string[]
	for p, h in pairs(trust) do
		t[#t + 1] = string.format("%s %s\n", h, p)
	end
	f:write(table.concat(t))
	f:close()
end

--- If {path} is a file: attempt to read the file, prompting the user if the file should be
--- trusted.
---
--- If {path} is a directory: return true if the directory is trusted (non-recursive), prompting
--- the user as necessary.
---
--- The user's choice is persisted in a trust database at
--- $XDG_STATE_HOME/nvim/trust.
---
---@since 11
---@see |:trust|
---
---@param path (string) Path to a file or directory to read.
---
---@param callback (function) If {path} is not trusted or does not exist, calls it with `nil`. Otherwise,
---        calls it with the contents of {path} if it is a file, or true if {path} is a directory.
local function read(path, callback)
	vim.validate("path", path, "string")
	local fullpath = vim.uv.fs_realpath(vim.fs.normalize(path))
	if not fullpath then
		callback(nil)
		return
	end

	local trust = read_trust()

	if trust[fullpath] == "!" then
		-- File is denied
		callback(nil)
		return
	end

	local contents, hash = compute_hash(fullpath, nil)
	if not contents then
		callback(nil)
		return
	end

	if trust[fullpath] == hash then
		-- File already exists in trust database
		callback(contents)
		return
	end

	-- local msg2 = " To enable it, choose (v)iew then run `:trust`:"
	-- local choices = "&ignore\n&view\n&deny"
	-- if hash == "directory" then
	-- 	msg2 = " DIRECTORY trust is decided only by name, not contents:"
	-- 	choices = "&ignore\n&view\n&deny\n&allow"
	-- end

	-- File either does not exist in trust database or the hash does not match
	-- local ok, result = pcall(
	-- 	vim.fn.confirm,
	-- 	string.format("exrc: Found untrusted code.%s\n%s", msg2, fullpath),
	-- 	choices,
	-- 	1
	-- )
	vim.ui.select({ "view", "ignore", "deny", "allow" }, {
		prompt = "Found untrusted code: " .. vim.fn.fnamemodify(path, ":~"),
	}, function(choice, result)
		if result == 1 then
			-- View
			vim.cmd("sview " .. fullpath)
			vim.keymap.set("n", "<localleader>t", vim.cmd.trust, { desc = "trust", buffer = true })
			vim.keymap.set("n", "<localleader>T", function()
				vim.cmd.trust()
				vim.cmd.source(fullpath)
			end, { desc = "trust and execute", buffer = true })
			callback(nil)
			return
		elseif result == 2 then
			-- Cancelled or ignored
			callback(nil)
			return
		elseif result == 3 then
			-- Deny
			trust[fullpath] = "!"
			contents = nil
		elseif result == 4 then
			-- Allow
			trust[fullpath] = hash
		end

		write_trust(trust)

		callback(contents)
	end)
end

local function exrc()
	local files = vim.fs.find({ ".nvim.lua", ".nvimrc", ".exrc" }, {
		type = "file",
		upward = true,
		limit = math.huge,
	})
	for _, file in ipairs(files) do
		read(file, function(trusted)
			if trusted then
				if vim.endswith(file, ".lua") then
					assert(loadstring(trusted, "@" .. file))()
				else
					vim.api.nvim_exec2(trusted, {})
				end
			end
		end)
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.schedule(exrc)
	end,
})
vim.api.nvim_create_autocmd("DirChanged", {
	callback = exrc,
})
