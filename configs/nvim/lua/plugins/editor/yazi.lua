return {
	"mikavilpas/yazi.nvim",
	keys = {
		{
			"<leader>ya",
			mode = { "n", "v" },
			"<Cmd>Yazi<CR>",
			desc = "Open Yazi at the current file",
		},
		{
			"<leader>yd",
			"<Cmd>Yazi cwd<CR>",
			desc = "Open Yazi in cwd",
		},
		{
			"<leader>yt",
			"<Cmd>Yazi toggle<CR>",
			desc = "Resume the last Yazi session",
		},
	},
	opts = {
		open_for_directories = false,
		open_multiple_tabs = false,
		floating_window_scaling_factor = 0.8,
		yazi_flocating_window_winblend = vim.o.pumblend,
		keymaps = {
			show_help = "<f1>",
		},
		highlight_groups = {
			hovered_buffer = { bg = "#1f1f28" },
			hovered_buffer_in_same_directory = { bg = "#1f1f28" },
		},
	},
}
