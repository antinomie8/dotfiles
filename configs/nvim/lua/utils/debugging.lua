---@param main_buf integer
---@param filepath string
local open_debugger_input = function(main_buf, filepath)
	local bufnr = vim.fn.bufadd(filepath)
	vim.fn.bufload(bufnr)

	-- set buffer options
	vim.bo[bufnr].buftype = ""
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].modifiable = true

	vim.keymap.set("n", "q", "<Cmd>wq<CR>", { buffer = bufnr, nowait = true, silent = true })

	-- Dimensions
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.ceil((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create the floating window
	local win_id = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})
	vim.wo[win_id].number = true
	vim.wo[win_id].relativenumber = false
	vim.wo[win_id].cursorline = true

	-- try to start debugging when closing the window
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win_id),
		callback = function()
			vim.b[main_buf].stdio_completed = true
			if vim.b[main_buf].compilation_completed and not require("dap").session() then
				vim.schedule(function() require("dap").continue() end)
			end
		end,
		once = true,
	})
end

---@param cmd table<string>
local function setup(cmd)
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.fs.basename(vim.api.nvim_buf_get_name(buf))
	local ext = vim.fs.ext(name)
	local root_name = name:sub(1, #name - #ext - 1)

	-- stdio redirection
	vim.b[buf].codelldb_stdio_redirection = nil
	vim.keymap.set("n", "<leader>oc", function()
		vim.b[buf].codelldb_stdio_redirection = not vim.b[buf].codelldb_stdio_redirection
	end, { desc = "Toggle codelldb stdio redirection", buffer = true })

	-- debugger input
	local input_filename = root_name .. ".in"
	vim.keymap.set("n", "<localleader>di", function()
		open_debugger_input(buf, input_filename)
	end, { desc = "Edit debugger input ", buffer = true })

	vim.keymap.set("n", "<localleader>dbg", function()
		vim.cmd("silent! write")
		local file = vim.api.nvim_buf_get_name(buf)

		vim.b[buf].compilation_completed = false

		local sources = { file }
		local cands = { "grader" }
		for _, name in ipairs(cands) do
			local source = vim.fs.joinpath(vim.fs.dirname(file), name .. ext)
			if vim.uv.fs_stat(source) then
				table.insert(sources, source)
			end
		end
		vim.system(vim.iter({
			cmd,
			sources,
			"-o",
			root_name,
		}):flatten():totable(), {}, function(obj)
			if obj.stderr and obj.stderr ~= "" then
				-- Fill quickfix list with errors/warnings
				local lines = vim.split(obj.stderr, "\n")
				vim.schedule(function()
					vim.fn.setqflist({}, "r", { title = "Compiler " .. (obj.code == 0 and "Warnings" or "Errors"), lines = lines })
					vim.cmd("copen")
				end)
				-- 	vim.notify(obj.stderr, (obj.code == 0) and vim.log.levels.WARN or vim.log.levels.ERROR, { title = "Compiler", icon = "" })
			end
			if obj.code == 0 then
				vim.notify("Compilation completed", vim.log.levels.INFO, { title = "Compiler", icon = "" })
				vim.b[buf].compilation_completed = true
				vim.b[buf].use_default_executable_path = true
				if vim.b[buf].stdio_completed then
					vim.schedule(function() require("dap").continue() end)
				end
			end
		end)

		if vim.uv.fs_stat(input_filename) then
			vim.b[buf].codelldb_stdio_redirection = true
			vim.b[buf].stdio_completed = true
			if vim.b[buf].compilation_completed then
				vim.schedule(function() require("dap").continue() end)
			end
		elseif vim.b[buf].codelldb_stdio_redirection == nil then
			local answer = vim.fn.input("Do you want to use stdio redirection ?")
			if answer:sub(1, 1) == "y" then
				vim.b[buf].codelldb_stdio_redirection = true
				open_debugger_input(buf, input_filename)
			else
				vim.b[buf].codelldb_stdio_redirection = false
				vim.b[buf].stdio_completed = true
				if vim.b[buf].compilation_completed then
					vim.schedule(function() require("dap").continue() end)
				end
			end
		end
	end, { buffer = true })

	vim.keymap.set("n", "<localleader>rm", function()
		for _, ext in ipairs({ ".in", ".out", ".err", "" }) do
			local filename = root_name .. ext
			if vim.uv.fs_stat(filename) then
				local ok, err = vim.uv.fs_unlink(filename)
				if not ok then
					vim.notify(
						string.format("Failed to remove %s: %s", filename, err),
						vim.log.levels.ERROR,
						{ title = "Debugger", icon = "" }
					)
				end
			end
		end
	end, { buffer = true })
end

return { setup = setup }
