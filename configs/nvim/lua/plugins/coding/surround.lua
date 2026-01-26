return {
	"kylechui/nvim-surround",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		keymaps = {
			insert = "<C-g>a",
			insert_line = "<C-g>A",
			normal = "ga",
			normal_cur = "gA",
			normal_line = "gz",
			normal_cur_line = "gZ",
			visual = "ga",
			visual_line = "gA",
			delete = "gd",
			change = "gR",
		},
	},
}
