local buf = vim.api.nvim_get_current_buf()

if vim.env.OLY and not vim.b[buf].oly_highlight then
	vim.b[buf].typst_root = vim.fn.expand("%:p:h") .. "/preview.typ"

	vim.cmd.cd(vim.fn.expand("%:p:h"))

	require("utils.oly").highlight({
		buffer = buf,
		ignore_pattern = "^/%*",
		divider_pattern = "^#divider%(%)%s*$",
	})
end
