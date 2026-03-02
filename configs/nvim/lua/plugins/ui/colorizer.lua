return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		filetypes = { "*" },
		lazy_load = true,
		buftypes = {},
		options = {
			parsers = {
				hex = { default = true },
				rgb = { enable = true },
			},
			display = {
				mode = "foreground", -- "background"|"foreground"|"virtualtext"
			},
		},
	},
}
