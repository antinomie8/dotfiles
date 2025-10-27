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
