local ls = require("utils.snippets.luasnip")
local s, t, i, d = ls.s, ls.t, ls.i, ls.d
local helpers = require("utils.snippets.helpers")
local get_visual = helpers.get_visual
local get_url = helpers.get_url

return {
	s(
		{
			trig = "lnk",
			dscr = "link",
			snippetType = "autosnippet",
			condition = helpers.not_in_string_comment,
		},
		{
			t("["),
			d(2, get_visual),
			t("]("),
			d(1, get_url),
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
