local ls = require("snippets.luasnip")
local s, t, i, d, f, fmt, make_cond =
      ls.s, ls.t, ls.i, ls.d, ls.f, ls.fmt, ls.make_cond
local helpers = require("snippets.helpers")
local get_visual = helpers.get_visual
local tex = require("snippets.tex_utils")

return {
	s(
		{
			trig = "$",
			dscr = "inline math mode",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.in_document * -- we actually have to use in_math instead
			make_cond(function()                            -- of in_text because the dollar sign negates it
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local line = vim.api.nvim_get_current_line()
				return (col == 0) or line:sub(col, col) ~= "\\"
			end),
		},
		{
			t("\\("),
			i(1),
			t("\\)"),
		}
	),
	s(
		{
			trig = "£",
			dscr = "display math mode",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document *
				make_cond(function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local line = vim.api.nvim_get_current_line()
				return (col == 0) or line:sub(col, col) ~= "\\"
			end),
		},
		{
			t("\\["),
			i(1),
			t("\\]"),
		}
	),
	s(
		{
			trig = "sm",
			dscr = "sum",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		fmt(
			[[
        \sum_{<>}^{<>} <>
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
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\sum_{\\text{cyc}} ")
	),
	s(
		{
			trig = "symsm",
			dscr = "symmetric sum",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\sum_{\\text{sym}} ")
	),
	s(
		{
			trig = "pd",
			dscr = "product",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		fmt(
			[[
        \prod_{<>}^{<>} <>
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
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\prod_{\\text{cyc}} ")
	),
	s(
		{
			trig = "sympd",
			dscr = "symmetric prod",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\prod_{\\text{sym}} ")
	),
	s(
		{
			trig = "ff",
			dscr = "fraction",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
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
			trig = "sq",
			dscr = "square root",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
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
			condition = tex.in_math * tex.not_in_cmd,
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
			condition = tex.in_math * tex.not_in_cmd,
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
			condition = tex.in_math * tex.not_in_cmd,
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
			condition = tex.in_math,
		},
		t("^2")
	),
	s(
		{
			trig = "cd",
			dscr = "cdot",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\cdot")
	),
	s(
		{
			trig = "Bx",
			dscr = "QED box",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\Box")
	),
	s(
		{
			trig = "ty",
			dscr = "lemniscate",
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\infty")
	),
	s(
		{
			trig = "all",
			dscr = "universal quantifier",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\forall")
	),
	s(
		{
			trig = "ex",
			dscr = "existensial quantifier",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = tex.in_math * tex.not_in_cmd,
		},
		t("\\exists")
	),
	s(
		{
			trig = "([%w%)%]%}])`",
			dscr = "superscript",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
			condition = tex.in_math,
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
			condition = tex.in_math,
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
			condition = tex.in_math,
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
			condition = tex.in_math,
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
