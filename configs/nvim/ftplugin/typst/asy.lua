local function open_asy_file(name)
	local root = vim.fn.fnamemodify(vim.b.typst_root, ":h") or vim.fn.getcwd()
	local fig_dir = root .. "/figures"
	local asy_path = fig_dir .. "/" .. name .. ".asy"

	local stat = vim.uv.fs_stat(fig_dir)
	if not stat then
		local ok, err = vim.uv.fs_mkdir(fig_dir, 493) -- 493 is decimal for 0755 in octal (rwxr-xr-x)
		if not ok then
			vim.notify("Failed to create directory: " .. err, vim.log.levels.ERROR, { title = "Asymptote", icon = "󰒕" })
		end
	elseif stat.type ~= "directory" then
		vim.notify(fig_dir .. " is not a directory !", vim.log.levels.ERROR, { title = "Asymptote", icon = "󰒕" })
	end

	local exists = vim.uv.fs_stat(asy_path)
	if not exists then
		local figure_line = string.format('#figure(image("figures/%s.pdf"))', name)
		local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_lines(0, row, row, false, { figure_line })
	end

	vim.cmd.edit(asy_path)

	-- Insert initial content into the new .asy buffer
	if not exists then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(require("static.lang.asymptote.preamble"), "\n"))
		vim.cmd("LiveRender")
	end
end

vim.api.nvim_buf_create_user_command(0, "Asy", function(arg)
	local name = arg.args
	if name == "" then
		vim.ui.input({ prompt = "New figure name" }, function(input)
			open_asy_file(input)
		end)
	else
		open_asy_file(name)
	end
end, {
	nargs = "?",
	complete = function()
		local results = {}

		local cwd = vim.uv.cwd()
		if not cwd then return results end

		local figures_dir = vim.fs.joinpath(cwd .. "/figures")

		local fd = vim.uv.fs_scandir(figures_dir)
		if not fd then return results end

		while true do
			local name, type = vim.uv.fs_scandir_next(fd)
			if not name then return results end

			if type == "file" and name:match("%.asy$") then
				local base_name = name:gsub("%.asy$", "")
				-- let the completion plugin handle the rest
				table.insert(results, base_name)
			end
		end
	end,
	desc = "Create a new Asymptote figure and insert Typst reference",
})

vim.keymap.set("n", "<leader>A", "<Cmd>Asy<CR>",
	{ desc = "Create a new Asymptote figure and insert Typst reference" })
