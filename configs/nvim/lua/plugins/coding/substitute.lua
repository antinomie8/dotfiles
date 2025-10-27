return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = { "GrugFar" },
		keys = {
			{
				"<leader>S",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
		opts = {
			engines = {
				ripgrep = {
					placeholders = {
						enabled = false,
					},
				},
			},
		},
	},
	{
		"chrisgrieser/nvim-rip-substitute",
		cmd = "RipSubstitute",
		opts = {
			popupWin = {
				title = " Substitute",
				border = "rounded",
				matchCountHlGroup = "Keyword",
				noMatchHlGroup = "ErrorMsg",
				position = "top",
				hideSearchReplaceLabels = false,
				hideKeymapHints = false,
				disableCompletions = false,
			},
		},
		keys = {
			{
				"<localleader>S",
				function()
					local ok, notifications = pcall(require, "noice.message.router")
					if ok then
						notifications.dismiss()
					end
					require("rip-substitute").sub()
				end,
				mode = { "n", "x" },
				desc = "Substitute in this buffer",
			},
		},
	},
}
