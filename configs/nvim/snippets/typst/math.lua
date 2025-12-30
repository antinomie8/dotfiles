local ls = require("snippets.luasnip")
local s, t, i, d, f, fmt, make_cond =
      ls.s, ls.t, ls.i, ls.d, ls.f, ls.fmt, ls.make_cond
local helpers = require("snippets.helpers")
local get_visual = helpers.get_visual

local typst = {}
typst.in_math = helpers.in_node("math")

return {
	s(
		{
			trig = "sm",
			dscr = "sum",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			[[
        sum_(<>)^(<>) <>
      ]],
			{
				i(1, "i = 0"),
				i(2, "n"),
				i(0),
			}
		)
	),
	s(
		{
			trig = "cycsm",
			dscr = "cyclic sum",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("sum_\"cyc\"")
	),
	s(
		{
			trig = "symsm",
			dscr = "symmetric sum",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("sum_\"sym\"")
	),
	s(
		{
			trig = "pd",
			dscr = "product",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			[[
        product_(<>)^(<>) <>
      ]],
			{
				i(1, "i = 0"),
				i(2, "n"),
				i(0),
			}
		)
	),
	s(
		{
			trig = "cycpd",
			dscr = "cyclic prod",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("product_\"cyc\"")
	),
	s(
		{
			trig = "sympd",
			dscr = "symmetric prod",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("product_\"sym\"")
	),
	s(
		{
			trig = "ff",
			dscr = "fraction",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			"(<>) / (<>)",
			{
				i(1),
				i(2),
			}
		)
	),
	s(
		{
			trig = "sq",
			dscr = "square root",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			"sqrt(<>)",
			{
				d(1, get_visual),
			}
		)
	),
	s(
		{
			trig = "cbrt",
			dscr = "cubic root",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			"root(3, <>)",
			{
				d(1, get_visual),
			}
		)
	),
	s(
		{
			trig = "op",
			dscr = "operatorname",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{
			t("op("),
			i(1),
			t(")"),
		}
	),
	s(
		{
			trig = "²",
			dscr = "square",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("^2")
	),
	s(
		{
			trig = "â",
			dscr = "^a",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("^a")
	),
	s(
		{
			trig = "all",
			dscr = "universal quantifier",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("forall")
	),
	s(
		{
			trig = "ex",
			dscr = "existensial quantifier",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("exists")
	),
	s(
		{
			trig = "([%w%)%]%}])`",
			dscr = "superscript",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt("<>^(<>)", {
			f(function(_, snip) return snip.captures[1] end),
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "([%w%)%]%}])@",
			dscr = "subscript",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt("<>_(<>)", {
			f(function(_, snip) return snip.captures[1] end),
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "([%w%)%]%}])__",
			dscr = "subscript and superscript",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt("<>^(<>)_(<>)", {
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			i(2),
		})
	),
}
