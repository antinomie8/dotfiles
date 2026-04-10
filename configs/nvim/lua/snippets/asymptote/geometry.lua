local ls = require("utils.snippets.luasnip")
local s, i, rep, fmt = ls.s, ls.i, ls.rep, ls.fmt
local helpers = require("utils.snippets.helpers")
local line_begin = helpers.line_begin

return {
	s(
		{
			trig = ".",
			dscr = "draw a point",
			snippetType = "autosnippet",
			condition = line_begin,
		},
		fmt(
			[[
				dot("$<>$", <>, dir(<>));
			]],
			{
				rep(1),
				i(1),
				rep(1),
			}
		)
	),
}
