return {
	{
		"https://codeberg.org/andyg/leap.nvim",
		dependencies = {
			"tpope/vim-repeat",
			"ggandor/flit.nvim",
			"rasulomaroff/telepath.nvim",
		},
		config = function()
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
			vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
			vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")

			require("telepath").use_default_mappings()
		end,
	},
	{
		"gbprod/substitute.nvim",
		keys = {
			{ "g,", function() require("substitute").operator() end, noremap = true },
			{ "g,,", function() require("substitute").operator({ motion = "iw" }) end, noremap = true },
			{ "g,;", function() require("substitute").line() end, noremap = true },
			{ "g,", function() require("substitute").visual() end, mode = "x", noremap = true },
		},
		opts = {
			on_substitute = function() require("yanky.integration").substitute() end,
		},
	},
	-- {
	--   "mfussenegger/nvim-treehopper",
	--   -- dependencies = {
	--   --   "smoka7/hop.nvim",
	--   -- },
	--   keys = {
	--     { "x", function() require("tsht").nodes() end, mode = { "o", "x" }, desc = "Region selection" },
	--   },
	--   config = function() require("tsht").config.hint_keys = { "a", "o", "e", "u", "i", "d", "h", "t", "n", "s" } end,
	-- },
	-- {
	--   "domharries/foldnav.nvim",
	--   version = "*",
	--   config = function()
	--     vim.g.foldnav = {
	--       flash = {
	--         enabled = true,
	--       },
	--     }
	--   end,
	--   keys = {
	--     { "<M-Left>", function() require("foldnav").goto_start() end },
	--     { "<M-Down>", function() require("foldnav").goto_next() end },
	--     { "<M-Up>", function() require("foldnav").goto_prev_start() end },
	--     { "<M-Right>", function() require("foldnav").goto_end() end },
	--   },
	-- },
}
