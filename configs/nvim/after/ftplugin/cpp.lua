-- Switch to header files using gf
vim.opt_local.suffixesadd:append({ ".h", ".hpp", ".cppm" })
vim.opt_local.path:append({ "include" })

-- debugging
vim.b.codelldb_stdio_redirection = nil
vim.keymap.set(
	"n",
	"<leader>oc",
	function() vim.b.codelldb_stdio_redirection = not vim.b.codelldb_stdio_redirection end,
	{ desc = "Toggle codelldb stdio redirection", buffer = true }
)

local open_floating_window = function(filepath)
	local buf = vim.api.nvim_get_current_buf()
	local bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(bufnr, filepath)

	-- if the file exists, load its contents
	if vim.fn.filereadable(filepath) == 1 then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.fn.readfile(filepath))
	end

	-- set buffer options
	vim.bo[bufnr].buftype = ""
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].modifiable = true

	vim.keymap.set("n", "q", "<Cmd>wq<CR>", { buffer = bufnr, nowait = true, silent = true })

	-- Dimensions
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
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
			vim.b[buf].stdio_completed = true
			if vim.b[buf].compilation_completed then
				vim.schedule(function() require("dap").continue() end)
			end
		end,
		once = true,
	})
end
local input_filename = vim.fn.expand("%:r") .. ".in"
vim.keymap.set(
	"n",
	"<localleader>di",
	function() open_floating_window(input_filename) end,
	{ desc = "Edit debugger input ", buffer = true }
)

vim.keymap.set("n", "<localleader>dbg", function()
	vim.cmd("silent! write")
	local buf = vim.api.nvim_get_current_buf()

	vim.b[buf].compilation_completed = false
	vim.system({
		"clang++",
		"-g",
		"-O0",
		"-std=c++23",
		vim.fn.expand("%"),
		"-o",
		vim.fn.expand("%:r"),
	}, {}, function(obj)
		if obj.stderr then
			if obj.stderr:match("error[^\n]*\n$") then
				vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Compiler", icon = "" })
			elseif obj.stderr ~= "" then
				vim.notify(obj.stderr, vim.log.levels.WARN, { title = "Compiler", icon = "" })
			end
		end
		if obj.code == 0 then
			vim.notify("Compilation completed", vim.log.levels.INFO, { title = "Debugging", icon = "" })
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
	elseif vim.b.codelldb_stdio_redirection == nil then
		local answer = vim.fn.input("Do you want to use stdio redirection ?")
		if answer:sub(1, 1) == "y" then
			vim.b[buf].codelldb_stdio_redirection = true
			open_floating_window(input_filename)
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
	for _, ext in ipairs({ "in", "out", "err" }) do
		local filename = vim.fn.expand("%:r") .. "." .. ext
		if vim.uv.fs_stat(filename) then
			local ok, err = vim.uv.fs_unlink(filename)
			if not ok then
				vim.notify(
					("Failed to remove %s: %s"):format(filename, err),
					vim.log.levels.ERROR,
					{ title = "Debugging", icon = "" }
				)
			end
		end
	end
end, { buffer = true })

-- compile and run SFML programs
vim.keymap.set(
	"n",
	"<localleader>sf",
	function() vim.system({ "compile_sfml", vim.fn.expand("%:p:r") }, { text = true }) end,
	{ expr = true, buffer = true }
)
