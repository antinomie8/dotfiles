return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		filetypes = { "*" },
		lazy_load = true,
		buftypes = {},
		options = {
			parsers = {
				rgb = { enable = true },
				names = { enable = false },
				hex = {
					rgb = true,            -- #RGB (3-digit)
					rgba = true,           -- #RGBA (4-digit)
					rrggbb = true,         -- #RRGGBB (6-digit)
					rrggbbaa = false,      -- #RRGGBBAA (8-digit)
					hash_aarrggbb = false, -- #AARRGGBB (QML-style, alpha first)
					aarrggbb = false,      -- 0xAARRGGBB
					no_hash = false,       -- hex without '#' at word boundaries
				},
			},
			display = {
				mode = "foreground", -- "background"|"foreground"|"virtualtext"
			},
		},
	},
}
