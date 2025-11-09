return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "│",
			highlight = "Indent",
		},
		scope = {
			show_start = false,
			show_end = false,
			highlight = "IndentScope",
		},
		exclude = {
			filetypes = {
				"undotree",
			},
		},
	},
	-- "saghen/blink.indent",
	-- event = { "BufReadPre", "BufNewFile" },
	-- opts = {
	-- 	static = {
	-- 		enabled = true,
	-- 		char = "│", -- ▎
	-- 		priority = 1,
	-- 		highlights = { "Indent" },
	-- 	},
	-- 	scope = {
	-- 		enabled = true,
	-- 		char = "│",
	-- 		priority = 1000,
	-- 		highlights = { "IndentScope" },
	-- 		underline = {
	-- 			enabled = false,
	-- 		},
	-- 	},
	-- },
}
