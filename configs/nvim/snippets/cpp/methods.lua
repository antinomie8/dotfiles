local ls = require("utils.snippets.luasnip")
local s, i, f, rep, fmt = ls.s, ls.i, ls.f, ls.rep, ls.fmt
local helpers = require("utils.snippets.helpers")
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "([^%w_])all%(",
			regTrig = true,
			wordTrig = false,
			dscr = "iterator range",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		fmt("<><>.begin(), <>.end()", {
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			rep(1),
		})
	),
	s(
		{
			trig = "([^%w_])rall%(",
			regTrig = true,
			wordTrig = false,
			dscr = "reverse iterator range",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		fmt("<><>.rbegin(), <>.rend()", {
			f(function(_, snip) return snip.captures[1] end),
			i(1),
			rep(1),
		})
	),
}
