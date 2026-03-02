local ls = require("snippets.luasnip")
local s, t, i, c, f = ls.s, ls.t, ls.i, ls.c, ls.f
local helpers = require("snippets.helpers")
local line_begin = helpers.line_begin
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "template",
			dscr = "template",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("template <typename "),
			i(1, "T"),
			t({ ">", "" }),
			i(0),
		}
	),
	s(
		{
			trig = "inc ",
			dscr = "include preprocessor directive",
			snippetType = "autosnippet",
			condition = line_begin,
			not_in_string_comment,
		},
		{
			c(1, {
				{ t("#include <"), i(1), t({ ">", "" }), i(0) },
				{ t('#include "'), i(1), t({ '"', "" }), i(0) },
			}),
		}
	),
	s(
		{
			trig = "fillarr",
			dscr = "virtual member function",
		},
		{
			t("for (auto& x : "),
			i(1),
			t(") cin >> x;"),
		}
	),
	s(
		{
			trig = "vi",
			dscr = "vector<int>",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("vector<int> "),
			i(1),
			t("("),
			i(2),
			t(");"),
		}
	),
	s(
		{
			trig = "vvi",
			dscr = "vector<int>",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("vector<vector<int>> "),
			i(1),
			t("("),
			i(2, "N"),
			t(", vector<int>("),
			i(3),
			t("));"),
		}
	),
	s(
		{
			trig = "vii",
			dscr = "vector<pair<int, int>>",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("vector<pair<int, int>> "),
			i(1),
			t("("),
			i(2),
			t(");"),
		}
	),
	s(
		{
			trig = "pi",
			dscr = "pair<int, int>",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		t("pair<int, int> ")
	),
}
