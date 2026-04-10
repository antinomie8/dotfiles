local ls = require("utils.snippets.luasnip")
local s, t, i, f = ls.s, ls.t, ls.i, ls.f

return {
	s(
		{
			trig = "^(%s*[%-%w]+:%s+)",
			dscr = "auto add semicolon",
			regTrig = true,
			snippetType = "autosnippet",
			condition = function()
				local col = vim.fn.col(".")
				local line = vim.fn.getline(".")
				return col - 1 == #line
			end,
		},
		{
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			t(";"),
			i(0),
		}
	),
	s(
		{
			trig = "!i",
			dscr = "!important keyword",
			snippetType = "autosnippet",
		},
		t("!important")
	),
}
