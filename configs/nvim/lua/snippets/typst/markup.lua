local ls = require("utils.snippets.luasnip")
local s, t, d = ls.s, ls.t, ls.d
local helpers = require("utils.snippets.helpers")
local get_visual = helpers.get_visual
local get_url = helpers.get_url
local typst = require("utils.snippets.typst_utils")

return {
	s({
			trig = "lnk",
			dscr = "link",
			snippetType = "autosnippet",
			condition = helpers.not_in_string_comment * typst.in_text,
		},
		{
			t("#link(\""),
			d(1, get_url),
			t("\")["),
			d(2, get_visual),
			t("]"),
		}
	),
}
