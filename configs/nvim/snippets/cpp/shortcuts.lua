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
			trig = "([^%w_]%s*)virt",
			dscr = "virtual member function",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
		},
		{
			f(function(_, snip) return snip.captures[1] end),
			t("virtual "),
		}
	),
}
