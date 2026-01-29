return {
	"mrjones2014/smart-splits.nvim",
	build = [[
PREFIX="${XDG_CONFIG_HOME:-$HOME/.config}"
KITTY_CONFIG_PATH="$PREFIX/kitty"
SMART_SPLITS_KITTY_PATH="$KITTY_CONFIG_PATH/smart_splits"
if [ -d "$KITTY_CONFIG_PATH" ]; then
	mkdir "$SMART_SPLITS_KITTY_PATH"
fi
cp -f ./kitty/neighboring_window.py "$KITTY_CONFIG_PATH/"
cp -f ./kitty/relative_resize.py "$SMART_SPLITS_KITTY_PATH/"
cp -f ./kitty/split_window.py "$SMART_SPLITS_KITTY_PATH/"
	]],
	lazy = false,
	keys = {
		-- for example `10<M-h>` will `resize_left` by `(10 * config.default_amount)`
		{ "<M-h>", function() require("smart-splits").resize_left() end },
		{ "<M-j>", function() require("smart-splits").resize_down() end },
		{ "<M-k>", function() require("smart-splits").resize_up() end },
		{ "<M-l>", function() require("smart-splits").resize_right() end },
		-- moving between splits
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, mode = { "n", "t" } },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, mode = { "n", "t" } },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, mode = { "n", "t" } },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "t" } },
		{ "<C-S-:>", function() require("smart-splits").move_cursor_previous() end },
		-- swapping buffers between windows
		{ "<C-Left>", function() require("smart-splits").swap_buf_left() end },
		{ "<C-Down>", function() require("smart-splits").swap_buf_down() end },
		{ "<C-Up>", function() require("smart-splits").swap_buf_up() end },
		{ "C-Right", function() require("smart-splits").swap_buf_right() end },
	},
	opts = {
		default_amount = 2,
	},
}
