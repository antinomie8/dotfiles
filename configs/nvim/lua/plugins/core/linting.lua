return {
	-- "mfussenegger/nvim-lint",
	-- event = { "BufReadPre", "BufNewFile" },
	-- config = function()
	--	 require("lint").linters_by_ft = {
	--		 bash = { "shellcheck" },
	--		 html = { "htmlhint" },
	--	 }
	--	 vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
	--		 callback = function() require("lint").try_lint() end,
	--	 })
	-- end,
}
