local ls = require("utils.snippets.luasnip")
local s, t, i, c, d, f, sn, rep, fmt =
      ls.s, ls.t, ls.i, ls.c, ls.d, ls.f, ls.sn, ls.rep, ls.fmt
local helpers = require("utils.snippets.helpers")
local get_visual = helpers.get_visual
local check_not_expanded = helpers.check_not_expanded
local not_in_string_comment = helpers.not_in_string_comment

local rec_switch
rec_switch = function()
	return sn(
		nil,
		c(1, {
			t(""),
			sn(nil, {
				t({ "", "\tcase " }),
				i(1),
				t({ ":", "" }),
				t("\t\t"),
				i(2),
				t({ "", "\t\tbreak;" }),
				d(3, rec_switch, {}),
			}),
		})
	)
end

-- contains the snippet's regex first capture group. Useful if snippet nodes need to access it.
local SNIP_CAPTURES_1

return {
	s(
		{
			trig = "if ",
			dscr = "conditional statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt("if <>) {\n\t<>\n}<>", {
			c(1, {
				{ t("("), i(1) },
				{ t("constexpr ("), i(1) },
			}),
			d(2, get_visual),
			i(0),
		})
	),
	s(
		{
			trig = "else ",
			dscr = "else statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$", "%sif"),
		},
		fmt("else {\n\t<>\n}<>", {
			d(1, get_visual),
			i(0),
		})
	),
	s(
		{
			trig = "elif ",
			dscr = "else if statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt("else if (<>) {\n\t<>\n}<>", {
			i(1),
			d(2, get_visual),
			i(0),
		})
	),
	s(
		{
			trig = "for ",
			dscr = "for loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				for (<>) {
					<>
				}<>
			]],
			{
				c(1, {
					{ i(1) },
					{ t("int "), i(1, "i"), t(" = 0; "), rep(1), t(" < "), i(2, "N"), t("; "), t("++"), rep(1) },
					{ i(3, "auto"), t(" "), i(1, "x"), t(" : "), i(2, "array") },
					{ i(1), t("; "), i(2), t("; "), i(3) },
				}),
				d(2, get_visual),
				i(0),
			}
		)
	),
	s(
		{
			trig = "while ",
			dscr = "while loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				while (<>) {
					<>
				}<>
			]],
			{
				i(1),
				d(2, get_visual),
				i(0),
			}
		)
	),
	s(
		{
			trig = "do ",
			dscr = "do while loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				do {
					<>
				} while (<>)
			]],
			{
				d(1, get_visual),
				i(2),
			}
		)
	),
	s(
		{
			trig = "switch ",
			dscr = "switch statement",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				switch (<>) {<>
				}
			]],
			{
				i(1),
				d(2, rec_switch, {}),
			}
		)
	),
	s(
		{
			trig = "namespace%s+([%w_]+)%s",
			regTrig = true,
			dscr = "namespace template",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		{
			t("namespace "),
			f(function(_, snip) return snip.captures[1] end),
			t({ " {", "" }),
			i(0),
			t({ "", "}" }),
		}
	),
	s(
		{
			trig = "([%a_][%w_ <>]+)(%s*%*%s*[%w_]+%s*[%({=]%s*new%s*)",
			dscr = "allocate memory using new",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			f(function(_, snip) return snip.captures[1] end),
			f(function(_, snip) return snip.captures[2] end),
			f(function(_, snip)
				SNIP_CAPTURES_1 = snip.captures[1]
				return " "
			end),
			c(1, {
				{
					f(function() return SNIP_CAPTURES_1 end),
					i(1),
				},
				{
					i(1),
				},
			}),
		}
	),
}
