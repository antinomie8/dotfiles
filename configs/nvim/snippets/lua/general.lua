local ls = require("snippets.luasnip")
local s, i, d, f, fmt = ls.s, ls.i, ls.d, ls.f, ls.fmt
local helpers = require("snippets.helpers")
local line_begin = helpers.line_begin
local get_visual = helpers.get_visual
local line_match = helpers.line_match
local line_not_match = helpers.line_not_match
local check_not_expanded = helpers.check_not_expanded
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "if ",
			dscr = "conditional statement",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("%s+then"),
		},
		fmt("if <> then\n\t<>\nend<>", {
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
			condition = not_in_string_comment * check_not_expanded("%s+do"),
		},
		fmt(
			[[
				for <> do
					<>
				end<>
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
			trig = "repeat ",
			dscr = "repeat until loop",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		fmt(
			[[
				repeat
					<>
				until <>
			]],
			{
				d(1, get_visual),
				i(2),
			}
		)
	),
	s(
		{
			trig = "function",
			dscr = "function",
			wordTrig = true,
			snippetType = "autosnippet",
			condition = (line_begin + line_match("^local function")) *
			            not_in_string_comment *
			            check_not_expanded("%(.*%)$"),
		},
		fmt(
			[[
				function <>(<>)
					<>
				end<>
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
			trig = "function",
			dscr = "function",
			wordTrig = true,
			snippetType = "autosnippet",
			condition = not_in_string_comment *
			            check_not_expanded("%(.*%)$") *
			            line_not_match("^%s*function$"),
		},
		fmt(
			[[
				function(<>)
					<>
				end<>
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
			trig = "func ",
			dscr = "function",
			wordTrig = true,
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("%(.*%)$"),
		},
		fmt("<>function(<>) <> end<>", {
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			d(2, get_visual),
			i(0),
		})
	),
}
