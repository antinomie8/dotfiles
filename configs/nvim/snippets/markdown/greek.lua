local ls = require("utils.snippets.luasnip")
local s, t = ls.s, ls.t
local md = {
	in_math = function() return vim.tbl_contains(vim.treesitter.get_captures_at_cursor(), "markup.math") end,
}

return {
	s({ trig = ";a", snippetType = "autosnippet" }, {
		t("\\alpha"),
	}, { condition = md.in_math }),
	s({ trig = ";b", snippetType = "autosnippet" }, {
		t("\\beta"),
	}, { condition = md.in_math }),
	s({ trig = ";g", snippetType = "autosnippet" }, {
		t("\\gamma"),
	}, { condition = md.in_math }),
	s({ trig = ";G", snippetType = "autosnippet" }, {
		t("\\Gamma"),
	}, { condition = md.in_math }),
	s({ trig = ";d", snippetType = "autosnippet" }, {
		t("\\delta"),
	}, { condition = md.in_math }),
	s({ trig = ";D", snippetType = "autosnippet" }, {
		t("\\Delta"),
	}, { condition = md.in_math }),
	s({ trig = ";e", snippetType = "autosnippet" }, {
		t("\\epsilon"),
	}, { condition = md.in_math }),
	s({ trig = ";ve", snippetType = "autosnippet" }, {
		t("\\varepsilon"),
	}, { condition = md.in_math }),
	s({ trig = ";z", snippetType = "autosnippet" }, {
		t("\\zeta"),
	}, { condition = md.in_math }),
	s({ trig = ";h", snippetType = "autosnippet" }, {
		t("\\eta"),
	}, { condition = md.in_math }),
	s({ trig = ";o", snippetType = "autosnippet" }, {
		t("\\theta"),
	}, { condition = md.in_math }),
	s({ trig = ";vo", snippetType = "autosnippet" }, {
		t("\\vartheta"),
	}, { condition = md.in_math }),
	s({ trig = ";O", snippetType = "autosnippet" }, {
		t("\\Theta"),
	}, { condition = md.in_math }),
	s({ trig = ";k", snippetType = "autosnippet" }, {
		t("\\kappa"),
	}, { condition = md.in_math }),
	s({ trig = ";l", snippetType = "autosnippet" }, {
		t("\\lambda"),
	}, { condition = md.in_math }),
	s({ trig = ";L", snippetType = "autosnippet" }, {
		t("\\Lambda"),
	}, { condition = md.in_math }),
	s({ trig = ";m", snippetType = "autosnippet" }, {
		t("\\mu"),
	}, { condition = md.in_math }),
	s({ trig = ";n", snippetType = "autosnippet" }, {
		t("\\nu"),
	}, { condition = md.in_math }),
	s({ trig = ";x", snippetType = "autosnippet" }, {
		t("\\xi"),
	}, { condition = md.in_math }),
	s({ trig = ";X", snippetType = "autosnippet" }, {
		t("\\Xi"),
	}, { condition = md.in_math }),
	s({ trig = ";i", snippetType = "autosnippet" }, {
		t("\\pi"),
	}, { condition = md.in_math }),
	s({ trig = ";I", snippetType = "autosnippet" }, {
		t("\\Pi"),
	}, { condition = md.in_math }),
	s({ trig = ";r", snippetType = "autosnippet" }, {
		t("\\rho"),
	}, { condition = md.in_math }),
	s({ trig = ";s", snippetType = "autosnippet" }, {
		t("\\sigma"),
	}, { condition = md.in_math }),
	s({ trig = ";S", snippetType = "autosnippet" }, {
		t("\\Sigma"),
	}, { condition = md.in_math }),
	s({ trig = ";t", snippetType = "autosnippet" }, {
		t("\\tau"),
	}, { condition = md.in_math }),
	s({ trig = ";f", snippetType = "autosnippet" }, {
		t("\\phi"),
	}, { condition = md.in_math }),
	s({ trig = ";vf", snippetType = "autosnippet" }, {
		t("\\varphi"),
	}, { condition = md.in_math }),
	s({ trig = ";F", snippetType = "autosnippet" }, {
		t("\\Phi"),
	}, { condition = md.in_math }),
	s({ trig = ";c", snippetType = "autosnippet" }, {
		t("\\chi"),
	}, { condition = md.in_math }),
	s({ trig = ";p", snippetType = "autosnippet" }, {
		t("\\psi"),
	}, { condition = md.in_math }),
	s({ trig = ";P", snippetType = "autosnippet" }, {
		t("\\Psi"),
	}, { condition = md.in_math }),
	s({ trig = ";w", snippetType = "autosnippet" }, {
		t("\\omega"),
	}, { condition = md.in_math }),
	s({ trig = ";W", snippetType = "autosnippet" }, {
		t("\\Omega"),
	}, { condition = md.in_math }),
}
