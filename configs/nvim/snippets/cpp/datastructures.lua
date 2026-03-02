local ls = require("snippets.luasnip")
local s, t, i, c, f, fmt = ls.s, ls.t, ls.i, ls.c, ls.f, ls.fmt
local helpers = require("snippets.helpers")
local check_not_expanded = helpers.check_not_expanded
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "class%s+([%w_]+)%s",
			regTrig = true,
			dscr = "class template",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				class <> <><>
				};
			]],
			{
				f(function(_, snip) return snip.captures[1] end),
				c(1, {
					{ t({ "{", "\t" }), i(1), i(0) },
					{ t(": public "), i(1), t({ " {", "\t" }), i(0) },
					{ t(": protected "), i(1), t({ " {", "\t" }), i(0) },
					{ t(": private "), i(1), t({ " {", "\t" }), i(0) },
				}),
				i(0),
			}
		)
	),
	s(
		{
			trig = "struct%s+([%w_]+)%s",
			regTrig = true,
			dscr = "struct template",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				struct <> <><>
				};
			]],
			{
				f(function(_, snip) return snip.captures[1] end),
				c(1, {
					{ t({ "{", "\t" }), i(1), i(0) },
					{ t(": public "), i(1), t({ " {", "\t" }), i(0) },
					{ t(": protected "), i(1), t({ " {", "\t" }), i(0) },
					{ t(": private "), i(1), t({ " {", "\t" }), i(0) },
				}),
				i(0),
			}
		)
	),
	s(
		{
			trig = "union%s+([%w_]+)%s",
			regTrig = true,
			dscr = "union template",
			snippetType = "autosnippet",
			condition = not_in_string_comment * check_not_expanded("{$"),
		},
		fmt(
			[[
				union <> {
					<>
				};
			]],
			{
				f(function(_, snip) return snip.captures[1] end),
				i(1),
			}
		)
	),
	s(
		{
			trig = "%s*u:",
			dscr = "public access specifier",
			regTrig = true,
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		t({ "public:", "\t" })
	),
	s(
		{
			trig = "%s*o:",
			dscr = "protected access specifier",
			regTrig = true,
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		t({ "protected:", "\t" })
	),
	s(
		{
			trig = "%s*i:",
			dscr = "private access specifier",
			regTrig = true,
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		t({ "private:", "\t" })
	),
}
