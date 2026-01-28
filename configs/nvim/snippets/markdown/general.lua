local ls = require("snippets.luasnip")
local s, t, i, d = ls.s, ls.t, ls.i, ls.d
local helpers = require("snippets.helpers")
local get_visual = helpers.get_visual

return {
	s(
		{
			trig = "lnk",
			dscr = "link",
			snippetType = "autosnippet",
		},
		{
			t("["),
			d(2, get_visual),
			t("]("),
			i(1, "https://"),
			t(")"),
		}
	),
	s(
		{
			trig = "cbl",
			dscr = "Code block",
			snippetType = "autosnippet",
		},
		{
			t("```"),
			i(1),
			t({ "", "" }),
			d(2, get_visual),
			t({ "", "```", "" }),
		}
	),
}
