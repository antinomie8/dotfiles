return {
	"andymass/vim-matchup",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("match-up").setup({
			matchparen = {
				offscreen = { method = "status_manual" },
			},
		})

		-- git conflicts
		vim.cmd.call(
			"matchup#util#append_match_words('<<<<<<<:|||||||:=======:>>>>>>>')"
		)
	end,
}
