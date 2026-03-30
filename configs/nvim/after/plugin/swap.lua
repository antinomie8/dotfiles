--- finds swapfiles for current file
---@param swapname (string) path to a swapfile for the current file
local function find_swapfiles(swapname)
	local dir = vim.fs.dirname(swapname)
	local base = vim.fn.fnamemodify(swapname, ":t:r")

	local pattern = "^" .. vim.pesc(base) .. "%.sw.$"

	local swaps = {}
	local fd = vim.uv.fs_scandir(dir)
	if not fd then return swaps end

	while true do
		local name, type = vim.uv.fs_scandir_next(fd)
		if not name then break end

		local swapfile = dir .. "/" .. name
		if type == "file" and name:match(pattern) and vim.fn.swapinfo(swapfile).dirty ~= 0 then
			table.insert(swaps, swapfile)
		end
	end

	return swaps
end

--- pretty-print elapsed time
---@param sec (integer) time elapsed in seconds between event and now
local function time_ago(sec)
	local diff = os.time() - sec
	if diff < 60 then
		return diff .. "s ago"
	elseif diff < 3600 then
		return math.floor(diff / 60) .. "m ago"
	elseif diff < 86400 then
		return math.floor(diff / 3600) .. "h ago"
	else
		return math.floor(diff / 86400) .. "d ago"
	end
end

---@param bufnr (integer) buffer number
---@param path (string) path to swapfile
local function recover(bufnr, path)
	-- recover
	if path then
		vim.cmd("silent! recover " .. vim.fn.fnameescape(path)) -- escape to prevent '%' expansion
	else
		vim.cmd("silent! recover")
	end

	-- reload language servers
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		client:_restart()
	end
	-- reload treesitter
	local parser = vim.treesitter.get_parser(bufnr)
	if parser then
		parser:invalidate(true)
	end
end

local function pick_swapfile(bufnr, file, swapname)
	require("snacks.picker").pick({
		title = "Swapfiles  ",

		finder = function()
			local swapfiles = find_swapfiles(swapname)
			local items = {}

			for _, swap in ipairs(swapfiles) do
				local stat = vim.uv.fs_stat(swap)
				local mtime = stat and os.date("%a %b %-d %H:%M:%S %Y", stat.mtime.sec) or ""
				local elapsed = stat and time_ago(stat.mtime.sec) or ""
				table.insert(items, {
					text = vim.fn.fnamemodify(swap, ":t"),
					file = file,
					path = swap,
					mtime = mtime,
					since = elapsed,
					info = vim.fn.swapinfo(swap),
				})
			end

			return items
		end,

		format = function(item)
			return {
				{ string.rep(" ", 7 - #item.since) },
				{ item.since, "Constant" },
				{ string.rep(" ", 3) },
				{ item.mtime, "Title" },
				{ string.rep(" ", 4) },
				{ item.text, "Keyword" },
			}
		end,

		preview = function(ctx)
			ctx.preview:set_title("diff")

			local item = ctx.item
			if not item then return end

			local tmpfile = vim.fn.tempname()

			local cmd = {
				"nvim",
				"-u", "NONE",
				"--headless",
				"-n",      -- no swapfile,
				"-r",      -- recover
				string.format("+w! %s", tmpfile), -- write to a temporary file
				"+q!",     -- quit after writing
				item.path, -- swap file to recover
			}

			vim.system(cmd, { text = true }, function(obj)
				if obj.code ~= 0 and obj.stderr and #obj.stderr > 0 then
					vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Swapfiles", icon = " " })
				end
				-- if the file doesn't exist, diff will fail with an error, so use an empty file instead
				local cmp = vim.uv.fs_stat(file) and file or "/dev/null"
				vim.system(
					{ "diff", "-u", cmp, tmpfile },
					{ text = true },
					function(diff)
						if diff.code ~= 0 and diff.stderr and #diff.stderr > 0 then
							vim.notify(diff.stderr, vim.log.levels.ERROR, { title = "Swapfiles", icon = " " })
						elseif not diff.stdout then
							return
						end

						-- modify context lines
						local lines = vim.split(diff.stdout, "\n")
						if #lines >= 1 and cmp == "/dev/null" then
							lines[1] = lines[1]:sub(1, 4) .. file .. lines[1]:sub(4 + #cmp + 1)
						end
						if #lines >= 2 then
							lines[2] = lines[2]:sub(1, 4) .. item.text .. lines[2]:sub(4 + #tmpfile + 1)
						end

						vim.schedule(function()
							pcall(ctx.preview.set_lines, ctx.preview, lines)
							ctx.preview:highlight({ ft = "diff" })
						end)
					end
				)
			end)
		end,

		actions = {
			confirm = function(picker, item)
				picker:close()
				recover(bufnr, item.path)
			end,
			delete = function(picker, item)
				vim.uv.fs_unlink(item.path)
				picker:find()
			end,
		},

		win = {
			input = {
				keys = {
					["<c-x>"] = { "delete", mode = { "n", "i" } },
				},
			},
			list = {
				keys = {
					["dd"] = { "delete" },
				},
			},
		},

		layout = function()
			if vim.o.columns >= 120 then
				-- telescope preset
				return {
					reverse = true,
					cycle = true,
					layout = {
						box = "horizontal",
						backdrop = false,
						width = 0.8,
						height = 0.9,
						border = "none",
						{
							box = "vertical",
							{ win = "list", title = " " .. file .. " ", title_pos = "center", border = true }, -- set title to file
							{ win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
						},
						{
							win = "preview",
							title = "{preview:Preview}",
							width = 0.45,
							border = true,
							title_pos = "center",
						},
					},
				}
			else
				return {
					cycle = true,
					preset = "vertical",
				}
			end
		end,
	})
end

vim.api.nvim_del_augroup_by_name("nvim.swapfile")
vim.api.nvim_create_autocmd("SwapExists", {
	callback = function(event)
		-- $VIMRUNTIME/lua/vim/_core/defaults.lua:676
		local info = vim.fn.swapinfo(vim.v.swapname)
		local user = vim.uv.os_get_passwd().username
		local iswin = 1 == vim.fn.has("win32")
		if not (info.error or info.pid <= 0 or (not iswin and info.user ~= user)) then
			vim.v.swapchoice = "e" -- Choose "(E)dit".
			vim.notify(
				("W325: Ignoring swapfile from Nvim process %d"):format(info.pid),
				vim.log.levels.WARN
			)
			return
		end

		local swapname = vim.v.swapname
		local swapfiles = find_swapfiles(swapname)
		if #swapfiles == 0 then return end -- bug

		vim.schedule(function()
			local options
			local prompt
			if #swapfiles == 1 then
				local stat = vim.uv.fs_stat(swapname)
				if stat then
					local mtime = time_ago(stat.mtime.sec)
					prompt = string.format("Found a swapfile for %s from %s:", event.file, mtime)
				else
					prompt = string.format("Found a swapfile for %s:", event.file)
				end
				options = {
					"Recover swapfile",
					"Edit file normally, leaving swapfile intact",
					"Delete swapfile and edit file normally",
				}
			else
				prompt = string.format("Found %d swapfiles for %s:", #swapfiles, event.file)
				options = {
					"View swapfiles",
					"Edit file normally, leaving swapfiles intact",
					"Delete all swapfiles and edit file normally",
				}
			end

			vim.ui.select(options, { prompt = prompt }, function(_, idx)
				if idx == 1 then
					if #swapfiles == 1 then
						-- only 1 swapfile: recover it
						recover(event.buf, swapname)
					else
						-- open picker
						pick_swapfile(event.buf, event.match, swapname)
					end
				elseif idx == 2 then
					-- don't do anything
					return
				elseif idx == 3 then
					-- delete all swapfiles
					for _, swap in ipairs(swapfiles) do
						vim.uv.fs_unlink(swap)
					end
				end
			end)
		end)

		-- don't trigger next SwapExists autocmds
		vim.v.swapchoice = "e"
	end,
})
