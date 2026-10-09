local ls = require("utils.snippets.luasnip")
local s, i, fmt = ls.s, ls.i, ls.fmt
local helpers = require("utils.snippets.helpers")
local first_line, line_begin = helpers.first_line, helpers.line_begin

return {
	s(
		{
			trig = "tmp",
			dscr = "template",
			snippetType = "autosnippet",
			condition = first_line * line_begin,
			hidden = true,
		},
		fmt(
			[[
				#import "@local/antoine:1.0.0": *
				#set text(lang: "fr")
				#show: setup.with(
					title: "<>",
					subtitle: "<>",
					author: "Antoine Saez Dumas",
					date: auto,
					maketitle: true,
				)
				
			]],
			{
				i(1),
				i(2),
			}
		)
	),
}
