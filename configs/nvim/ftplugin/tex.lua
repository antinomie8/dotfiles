local buf = vim.api.nvim_get_current_buf()

if vim.env.OLY and not vim.b[buf].oly_highlight then
	vim.b[buf].vimtex_main = vim.fn.expand("%:p:h") .. "/preview.tex"

	vim.cmd.cd(vim.fn.expand("%:p:h"))

	require("utils.oly").highlight({
		buffer = buf,
		ignore_pattern = "\\iffalse",
		divider_pattern = "^\\hrulebar%s*$",
	})
end
