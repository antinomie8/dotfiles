local extras = require("luasnip.extras")
local ls = require("luasnip")

local fmt = require("luasnip.extras.fmt").fmta
local make_condition = require("luasnip.extras.conditions").make_condition

local aliases = {
	s = ls.snippet,
	t = ls.text_node,
	i = ls.insert_node,
	c = ls.choice_node,
	d = ls.dynamic_node,
	f = ls.function_node,
	sn = ls.snippet_node,
	r = ls.restore_node,
	l = ls.lambda,

	rep = extras.rep,
	m = extras.match,
	n = extras.nonempty,
	dl = extras.dynamic_lambda,

	fmt = fmt,
	make_cond = make_condition,
}

return aliases
