return {
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		opts = {
			auto_resize_height = true,
			preview = {
				win_height = 9,
				show_title = false,
				show_scroll_bar = false,
				buf_label = false,
			},
			filter = {
				fzf = {
					extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
				},
			},
		},
	},
	{
		"stevearc/quicker.nvim",
		ft = "qf",
		opts = function()
			vim.keymap.set("n", "<leader>qq", function() require("quicker").toggle() end, { desc = "Toggle quickfix" })
			vim.keymap.set(
				"n",
				"<leader>ql",
				function() require("quicker").toggle({ loclist = true }) end,
				{ desc = "Toggle loclist" }
			)
			return {
				opts = {
					number = true,
				},
				keys = {
					{
						">",
						function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end,
						desc = "Expand quickfix context",
					},
					{
						"<",
						function() require("quicker").collapse() end,
						desc = "Collapse quickfix context",
					},
				},
				type_icons = {
					E = "󰅚 ",
					W = "󰀪 ",
					I = " ",
					N = " ",
					H = " ",
				},
			}
		end,
	},
}
