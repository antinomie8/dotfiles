local ls = require("utils.snippets.luasnip")
local s, t, i, c, d, sn, fmt =
      ls.s, ls.t, ls.i, ls.c, ls.d, ls.sn, ls.fmt
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
				t({ "", "\t" }),
				i(1),
				t({ ")", "" }),
				t("\t\t"),
				i(2),
				t({ "", "\t\t;;" }),
				d(3, rec_switch, {}),
			}),
		})
	)
end

return {
	s(
		{
			trig = "if ",
			dscr = "conditional statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*then$"),
		},
		fmt("if <>; then\n\t<>\nfi<>", {
			i(1),
			d(2, get_visual),
			i(0),
		})
	),
	s(
		{
			trig = "elif ",
			dscr = "conditional statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*then$"),
		},
		fmt("elif <>; then\n\t<>", {
			i(1),
			d(2, get_visual),
		})
	),
	s(
		{
			trig = "for ",
			dscr = "for loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*do$"),
		},
		fmt(
			[[
				for <> in <>; do
					<>
				done<>
			]],
			{
				i(1),
				i(2),
				d(3, get_visual),
				i(0),
			}
		)
	),
	s(
		{
			trig = "while ",
			dscr = "while loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*do$"),
		},
		fmt(
			[[
				while <>; do
					<>
				done <>
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
			trig = "until ",
			dscr = "until loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*do$"),
		},
		fmt(
			[[
				until <>; do
					<>
				done <>
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
			trig = "select ",
			dscr = "select loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded(";%s*do$"),
		},
		fmt(
			[[
				select <> in <>; do
					<>
				done <>
			]],
			{
				i(1),
				i(2),
				d(3, get_visual),
				i(0),
			}
		)
	),
	s(
		{
			trig = "if [",
			dscr = "test condition",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("if [[ "),
			i(1),
			t(" ]]"),
		}
	),
	s(
		{
			trig = "elif [",
			dscr = "test condition",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("elif [[ "),
			i(1),
			t(" ]]"),
		}
	),
	s(
		{
			trig = "while [",
			dscr = "test condition",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("while [[ "),
			i(1),
			t(" ]]"),
		}
	),
	s(
		{
			trig = "func",
			name = "function",
			dscr = "define a function",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				function <> {
					<>
				}
			]],
			{
				i(1),
				i(0),
			}
		)
	),
	s(
		{
			trig = "case ",
			dscr = "switch statement",
			wordTrig = false,
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("%s+in$"),
		},
		fmt(
			[[
				case <> in<>
				esac
			]],
			{
				i(1),
				d(2, rec_switch, {}),
			}
		)
	),
}
