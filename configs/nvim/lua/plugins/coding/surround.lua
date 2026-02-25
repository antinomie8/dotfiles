return {
	"kylechui/nvim-surround",
	version = "*",
	lazy = false,
	init = function()
		vim.g.nvim_surround_no_mappings = true
	end,
	keys = {
		{ "<c-g>p", "<plug>(nvim-surround-insert)",          mode = "i", desc = "add a surrounding pair around the cursor (insert mode)" },
		{ "<c-g>P", "<plug>(nvim-surround-insert-line)",     mode = "i", desc = "add a surrounding pair around the cursor, on new lines (insert mode)" },
		{ "yp",     "<plug>(nvim-surround-normal)",          mode = "n", desc = "add a surrounding pair around a motion (normal mode)" },
		{ "ypp",    "<plug>(nvim-surround-normal-cur)",      mode = "n", desc = "add a surrounding pair around the current line (normal mode)" },
		{ "yP",     "<plug>(nvim-surround-normal-line)",     mode = "n", desc = "add a surrounding pair around a motion, on new lines (normal mode)" },
		{ "yPP",    "<plug>(nvim-surround-normal-cur-line)", mode = "n", desc = "add a surrounding pair around the current line, on new lines (normal mode)" },
		{ "s",      "<plug>(nvim-surround-visual)",          mode = "x", desc = "add a surrounding pair around a visual selection" },
		{ "gs",     "<plug>(nvim-surround-visual-line)",     mode = "x", desc = "add a surrounding pair around a visual selection, on new lines" },
		{ "dp",     "<plug>(nvim-surround-delete)",          mode = "n", desc = "delete a surrounding pair" },
		{ "cp",     "<plug>(nvim-surround-change)",          mode = "n", desc = "change a surrounding pair" },
		{ "cP",     "<plug>(nvim-surround-change-line)",     mode = "n", desc = "change a surrounding pair, putting replacements on new lines" },
	},
}
