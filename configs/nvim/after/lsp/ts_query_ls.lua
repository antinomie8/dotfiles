local path = vim.fn.stdpath("data") .. "/site/pack/nvim-treesitter/.tsqueryrc.json"
local tsqueryrc = require("utils").loadfile(path)
if not tsqueryrc then return {} end

local init_options = vim.tbl_deep_extend("force", vim.json.decode(tsqueryrc), {
	parser_aliases = {
		asymptote = "cpp",
	},
	valid_predicates = {
		in_asy = {
			parameters = {},
			description = "Check the current file is an asymptote file",
		},
	},
})

return {
	init_options = init_options,
}
