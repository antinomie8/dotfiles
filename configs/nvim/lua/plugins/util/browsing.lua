return {
	"chrishrb/gx.nvim",
	keys = {
		{ "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
	},
	cmd = { "Browse" },
	init = function()
		vim.g.netrw_nogx = 1 -- disable netrw gx
	end,
	submodules = false,
	opts = {
		select_prompt = false,
		handler_options = {
			search_engine = "duckduckgo",
		},
		handlers = {
			oly = {
				name = "oly",
				filetype = { "typst" },
				handle = function(mode, line, _)
					local name = require("gx.helper").find(line, mode, 'oly%("([^"]*)"')
					if name then
						return "oly://gen?name=" .. name
					else
					end
				end,
			},
		},
	},
}
