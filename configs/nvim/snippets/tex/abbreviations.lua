local ls = require("snippets.luasnip")
local i, s, t, c = ls.i, ls.s, ls.t, ls.c
local tex = require("snippets.tex_utils")

return {
	s(
		{
			trig = "SPA ",
			dscr = "reductio ad absurdum",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			c(1, {
				{ t("Supposons par l'absurde "), i(1) },
				{ t("Assume for the sake of contradiction "), i(1)  },
			})
		}
	),
	s(
		{
			trig = "Wlog ",
			dscr = "without loss of generality",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			c(1, {
				{ t("Supposons sans perte de généralité que "), i(1)  },
				{ t("Without loss of generality, "), i(1)  },
			})
		}
	),
	s(
		{
			trig = "wlog ",
			dscr = "without loss of generality",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			c(1, {
				{ t("sans perte de généralité "), i(1)  },
				{ t("without loss of generality "), i(1)  },
			})
		}
	),
	s(
		{
			trig = "apcr ",
			dscr = "à partir d'un certain rang",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			t("à partir d'un certain rang ")
		}
	),
	s(
		{
			trig = "Apcr ",
			dscr = "À partir d'un certain rang",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			t("À partir d'un certain rang ") }
	),
	s(
		{
			trig = "wrt ",
			dscr = "with respect to",
			snippetType = "autosnippet",
			condition = tex.in_text * tex.in_document * tex.not_in_cmd,
		},
		{
			c(1, {
				{ t("par rapport à "), i(1)  },
				{ t("with respect to "), i(1)  },
			})
		}
	),
}
