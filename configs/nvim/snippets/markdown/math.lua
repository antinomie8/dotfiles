local ls = require("snippets.luasnip")
local s, t, i, d, f, fmt, make_cond =
      ls.s, ls.t, ls.i, ls.d, ls.f, ls.fmt, ls.make_cond
local helpers = require("snippets.helpers")
local get_visual = helpers.get_visual
local check_not_expanded = helpers.check_not_expanded
local md  = {
	in_math = function() return vim.tbl_contains(vim.treesitter.get_captures_at_cursor(), "markup.math") end
}

local check_floor_not_expanded = make_cond(function() return check_not_expanded("\\rfloo") end)
local check_ceil_not_expanded = make_cond(function() return check_not_expanded("\\rcei") end)

return {
	s(
		{
			trig = "sm",
			dscr = "sum",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt(
			[[
				\sum_{<>}^{<>}<>
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
			trig = "pd",
			dscr = "product",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt(
			[[
				\prod_{<>}^{<>}<>
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
			trig = "ff",
			dscr = "fraction",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt(
			"\\frac{<>}{<>}",
			{
				i(1),
				i(2),
			}
		)
	),
	s(
		{
			trig = "floor",
			dscr = "floor",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math * check_floor_not_expanded,
		},
		fmt("\\left\\lfloor <> \\right\\rfloor", {
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "ceil",
			dscr = "ceil",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math * check_ceil_not_expanded,
		},
		fmt("\\left\\lceil <> \\right\\rceil", {
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "set",
			dscr = "curly braces",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt("\\left\\{ <> \\right\\}", {
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "abs",
			dscr = "module",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt("\\left\\lvert <> \\right\\rvert", {
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "nrm",
			dscr = "vector norm",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt("\\left\\lVert <> \\right\\rVert", {
			d(1, get_visual),
		})
	),
	s(
		{
			trig = "sq",
			dscr = "square root",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt(
			"\\sqrt{<>}",
			{
				d(1, get_visual),
			}
		)
	),
	s(
		{
			trig = "cbrt",
			dscr = "cubic root",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math
		},
		fmt(
			"\\sqrt[3]{<>}",
			{
				d(1, get_visual),
			}
		)
	),
	s(
		{
			trig = "tx",
			dscr = "text",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		{
			t("\\text{"),
			i(1),
			t("}"),
		}
	),
	s(
		{
			trig = "op",
			dscr = "operatorname",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		{
			t("\\operatorname{"),
			i(1),
			t("}"),
		}
	),
	s(
		{
			trig = "²",
			dscr = "square",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("^2")
	),
	s(
		{
			trig = "cd",
			dscr = "cdot",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("\\cdot")
	),
	s(
		{
			trig = "Bx",
			dscr = "QED box",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("\\Box")
	),
	s(
		{
			trig = "ty",
			dscr = "lemniscate",
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("\\infty")
	),
	s(
		{
			trig = "all ",
			dscr = "universal quantifier",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("\\forall ")
	),
	s(
		{
			trig = "ex ",
			dscr = "existensial quantifier",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		t("\\exists ")
	),
	s(
		{
			trig = "ds",
			dscr = "displaystyle",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		{
			t("\\displaystyle"),
		}
	),
	s(
		{
			trig = "([%w%)%]%}])`",
			dscr = "superscript",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		fmt("<>^{<>}", {
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
			condition = md.in_math,
		},
		fmt("<>_{<>}", {
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
			condition = md.in_math,
		},
		fmt("<>^{<>}_{<>}", {
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			i(2),
		})
	),
	s(
		{
			trig = "(\\?left)",
			dscr = "pairs",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = md.in_math,
		},
		{
			t("\\left"),
			d(2, get_visual),
			f(function(arg)
				if arg[1][1] == "{" then
					return "\\"
				else
					return ""
				end
			end, 1),
			i(1),
			t("\\right"),
			f(function(arg)
				if arg[1][1] == "{" or arg[1][1] == "\\{" then
					return "\\}"
				elseif arg[1][1] == "(" then
					return ")"
				elseif arg[1][1] == "[" then
					return "]"
				elseif arg[1][1]:sub(1, 3) == "\\ll" then
					return "\\rr" .. arg[1][1]:sub("4", "-1")
				elseif arg[1][1]:sub(1, 2) == "\\l" then
					return "\\r" .. arg[1][1]:sub("3", "-1")
				else
					return arg[1][1]:sub(1,1)
				end
			end, 1),
		}
	),
}
