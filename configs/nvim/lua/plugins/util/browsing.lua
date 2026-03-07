return {
	"chrishrb/gx.nvim",
	keys = {
		{ "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
	},
	cmd = { "Browse" },
	init = function()
		vim.g.netrw_nogx = 1 -- disable netrw gx
	end,
	submodules = false,
	opts = {
		select_prompt = false,
		handler_options = {
			search_engine = "duckduckgo",
		},
	},
}
