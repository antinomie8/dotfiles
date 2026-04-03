return {
	"nvim-tree/nvim-web-devicons",
	lazy = true,
	opts = {
		override_by_extension = {
			["asy"] = {
				icon = "󰒕",
				color = "#ff0000",
				name = "Asymptote",
			},
		},
	},
}
