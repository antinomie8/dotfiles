vim.api.nvim_create_autocmd("User", {
	pattern = { "TSInstall", "TSUpdate" },
	callback = function()
		require("nvim-treesitter.parsers").tsqx = {
			install_info = {
				url = "https://github.com/extouchtriangle/tree-sitter-tsqx",
			},
			filetype = "tsqx",
		}
	end,
})

vim.keymap.set("n", "<localleader>p", function()
	vim.system({ "python", "-m", "tsqx", "-p", vim.fn.expand("%"), "|", "asy", "-f", "pdf", "-V" })
end, { desc = " tsqx -> asy compile and open", buffer = true })

vim.keymap.set("n", "<localleader>c", function()
	vim.system({ "python", "-m", "tsqx", "-p", vim.fn.expand("%"), "|", "asy", "-f", "pdf" })
end, { desc = " tsqx -> asy compile", buffer = true })
