return {
	"Julian/lean.nvim",
	ft = "lean",

	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "lean",
			callback = function(event)
				vim.diagnostic.enable(false, { bufnr = event.buf })
			end,
		})
	end,
	opts = {
		mappings = true,
		goal_markers = {
			unsolved = "󱌣",
			accomplished = "󰄴",
		},
	},
}
