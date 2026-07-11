local ls = require("utils.snippets.luasnip")
local s, t, i, c, d, f, fmt = ls.s, ls.t, ls.i, ls.c, ls.d, ls.f, ls.fmt
local helpers = require("utils.snippets.helpers")
local get_visual = helpers.get_visual
local typst = require("utils.snippets.typst_utils")

local snippets = {
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
				i(1, "k = 1"),
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
				i(1, "k = 1"),
				i(2, "n"),
				i(0),
			}
		)
	),
	s(
		{
			trig = "lm",
			dscr = "limit",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		fmt(
			[[
				lim_(<>) <>
      ]],
			{
				c(1, {
					{ i(1, "n -> +oo") },
					{ i(1, "x -> +oo") },
					{ i(1, "x -> 0") },
				}),
				i(2),
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
			trig = "rr",
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
	s({
			trig = "arr",
			dscr = "arrow",
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{ t("arrow("), d(1, get_visual), t(")") }
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
			trig = "sb ",
			dscr = "subset",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("subset.eq ")
	),
	s(
		{
			trig = "cm ",
			dscr = "function composition",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("compose ")
	),
	s(
		{
			trig = "all ",
			dscr = "universal quantifier",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("forall ")
	),
	s(
		{
			trig = "al ",
			dscr = "universal quantifier",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("forall ")
	),
	s(
		{
			trig = "ex ",
			dscr = "existensial quantifier",
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		t("exists ")
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
	s({
			trig = "([%a%)%]%}])(%d)",
			dscr = "integer index",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{
			f(function(_, snip) return snip.captures[1] end),
			f(function(_, snip) return "_" .. snip.captures[2] end),
		}
	),
	s({
			trig = "([a-zA-Z])bar",
			dscr = "bar",
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{ t("bar("), f(function(_, snip) return snip.captures[1] end), t(")") }
	),
	s({
			trig = "([a-zA-Z])hat",
			dscr = "hat",
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{ t("hat("), f(function(_, snip) return snip.captures[1] end), t(")") }
	),
	s({
			trig = "([a-zA-Z])til",
			dscr = "tilde",
			regTrig = true,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{ t("tilde("), f(function(_, snip) return snip.captures[1] end), t(")") }
	),
	s({ trig = "inv", dscr = "inverse", wordTrig = false, snippetType = "autosnippet", condition = typst.in_math },
		t("^(-1)")
	),
	s({ trig = "df", snippetType = "autosnippet", condition = typst.in_math },
		t("dif")
	),
	s({ trig = "upr", dscr = "upright text", snippetType = "autosnippet" },
		{ t("upright(\""), i(1), t("\")") }
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
			trig = "⁽",
			dscr = "superscipt parenthesis",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = typst.in_math,
		},
		{
			t("^("),
			i(0),
			t(")"),
		}
	),
}

local sets = {
	["NN*"] = "NN^*",
	["ZZ+"] = "ZZ_+",
	["ZZ*"] = "ZZ^*",
	["QQ+"] = "QQ_+",
	["QQ*"] = "QQ^*",
	["RR+"] = "RR_+",
	["RR*"] = "RR^*",
	["R+*"] = "RR_+^*",
}

for trigger, replace in pairs(sets) do
	table.insert(snippets,
		s({
				trig = trigger,
				dscr = trigger,
				wordTrig = false,
				snippetType = "autosnippet",
			},
			t(replace)
		)
	)
end

for i, exp in ipairs({ "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰" }) do
	table.insert(snippets,
		s({
				trig = exp,
				wordTrig = false,
				snippetType = "autosnippet",
			},
			t("^" .. i % 10)
		)
	)
end
table.insert(snippets,
	s({
			trig = "⁻",
			wordTrig = false,
			snippetType = "autosnippet",
		},
		{ t("^(-"), i(1), t(")") }
	)
)

return snippets
