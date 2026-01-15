local ls = require("snippets.luasnip")
local s, i, d, fmt = ls.s, ls.i, ls.d, ls.fmt
local helpers = require("snippets.helpers")
local line_begin = helpers.line_begin
local get_visual = helpers.get_visual

return {
	s({ trig = "!thm", dscr = "theorem", snippetType = "autosnippet", cond = line_begin },
		fmt(
			[[
				#theorem[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!T", dscr = "theorem", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#theorem[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!lem", dscr = "lemma", snippetType = "autosnippet", cond = line_begin },
		fmt(
			[[
				#lemma[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!L", dscr = "lemma", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#lemma[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!P", dscr = "proof", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#proof[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!cor", dscr = "corollary", snippetType = "autosnippet", cond = line_begin },
		fmt(
			[[
				#corollary[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!C", dscr = "corollary", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#corollary[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!prop", dscr = "proposition", snippetType = "autosnippet", cond = line_begin },
		fmt(
			[[
				#proposition[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!exer", dscr = "exercise", snippetType = "autosnippet", cond = line_begin },
		fmt(
			[[
				#exercise[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!E", dscr = "exercise", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#exercise[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!R", dscr = "remark", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#remark[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!D", dscr = "definition", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#definition[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!N", dscr = "notation", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#notation[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s({ trig = "!S", dscr = "solution", snippetType = "autosnippet", cond = line_begin, hidden = true },
		fmt(
			[[
				#solution[
					<>
				]
			]],
			{
				i(1),
			}
		)
	),
	s(
		{
			trig = "voc",
			dscr = "vocabulary",
		},
		fmt(
			'#vocab("<>")',
			{
				d(1, get_visual),
			}
		)
	),
}
