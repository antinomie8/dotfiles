vim.b.current_compiler = "typst" -- disable default compiler in $VIMRUNTIME/compiler/typst.vim
vim.bo.makeprg = "typst compile --diagnostic-format short "
                 .. vim.fn.shellescape(vim.b.typst_root or vim.api.nvim_buf_get_name(0))

vim.api.nvim_buf_create_user_command(0, "Asymptote", function(arg)
	local name = arg.args
	if name == "" then
		vim.notify("Error: Name argument is required", vim.log.levels.ERROR, { title = "Asymptote", icon = "󰒕" })
		return
	end

	local root = vim.fn.fnamemodify(vim.b.typst_root, ":h") or vim.fn.getcwd()
	local fig_dir = root .. "/figures"

	if vim.fn.isdirectory(fig_dir) == 0 then
		vim.fn.mkdir(fig_dir, "p")
	end

	local figure_line = string.format('#figure(image("figures/%s.pdf"))', name)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(0, row, row, false, { figure_line })

	local asy_path = fig_dir .. "/" .. name .. ".asy"

	vim.cmd.edit(asy_path)

	-- Insert initial content into the new .asy buffer if it's empty
	if vim.api.nvim_buf_line_count(0) <= 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" then
		-- vim.api.nvim_buf_set_lines(0, 0, 0, false, { "", "" })
	end
end, {
	nargs = 1,
	desc = "Create a new Asymptote figure and insert Typst reference",
})
