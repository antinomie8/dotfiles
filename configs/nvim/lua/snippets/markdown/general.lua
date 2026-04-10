local ls = require("utils.snippets.luasnip")
local s, t, i, d = ls.s, ls.t, ls.i, ls.d
local helpers = require("utils.snippets.helpers")
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
	s(
		{
			trig = "conceal",
			dscr = "concealed text",
		},
		{
			t({ "<details>", "" }),
			t("<summary>"), i(1), t("</summary>"),
			t({ "", "" }),
			i(2),
			t({ "", "" }),
			t("</details>"),
		}
	),
}
