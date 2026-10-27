return {
	"smart-splits-nvim/smart-splits.nvim",
	lazy = false,
	dependencies = {
		{
			"smart-splits-nvim/backend-kitty",
			module = "smart-splits-backend-kitty",
		},
	},
	keys = {
		-- for example `10<M-h>` will `resize_left` by `(10 * config.resize.amount)`
		{ "<C-M-h>", function() require("smart-splits").resize_left() end },
		{ "<C-M-j>", function() require("smart-splits").resize_down() end },
		{ "<C-M-k>", function() require("smart-splits").resize_up() end },
		{ "<C-M-l>", function() require("smart-splits").resize_right() end },
		-- moving between splits
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, mode = { "n", "t" } },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, mode = { "n", "t" } },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, mode = { "n", "t" } },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "t" } },
		-- swapping buffers between windows
		{ "<C-Left>", function() require("smart-splits").swap_buf_left() end },
		{ "<C-Down>", function() require("smart-splits").swap_buf_down() end },
		{ "<C-Up>", function() require("smart-splits").swap_buf_up() end },
		{ "C-Right", function() require("smart-splits").swap_buf_right() end },
	},
	opts = {
		resize = { amount = 2 },
		mux = {
			backend = "smart-splits-backend-kitty",
		},
	},
}
