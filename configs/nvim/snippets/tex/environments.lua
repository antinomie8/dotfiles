local ls = require("utils.snippets.luasnip")
local s, t, i, c, d, sn, rep, fmt =
      ls.s, ls.t, ls.i, ls.c, ls.d, ls.sn, ls.rep, ls.fmt
local helpers = require("utils.snippets.helpers")
local line_begin = helpers.line_begin
local tex = require("utils.snippets.tex_utils")

local rec_item
rec_item = function()
	return sn(nil,
		c(1, {
			t(""),
			sn(nil, {
				t({ "", "\t\\item " }),
				i(1),
				d(2, rec_item, {}),
			}),
		})
	)
end

return {
	s(
		{
			trig = "\\?beg",
			dscr = "environment",
			regTrig = true,
			snippetType = "autosnippet",
			condition = line_begin,
		},
		fmt(
			[[
				\begin{<>}
					<>
				\end{<>}
			]],
			{
				i(1),
				i(2),
				rep(1),
			}
		)
	),
	s(
		{
			trig = "\\?se",
			dscr = "section",
			regTrig = true,
			snippetType = "autosnippet",
			condition = tex.in_text * line_begin, -- pernicieux quand textwidth -> line_begin
		},
		fmt(
			[[
				\section<>{<>}
			]],
			{
				i(2),
				i(1),
			}
		)
	),
	s(
		{
			trig = "\\?sb",
			dscr = "section",
			regTrig = true,
			snippetType = "autosnippet",
			condition = tex.in_text * line_begin,
		},
		fmt(
			[[
				\subsection<>{<>}
			]],
			{
				i(2),
				i(1),
			}
		)
	),
	s(
		{
			trig = "\\?ls",
			dscr = "unordered list",
			regTrig = true,
			snippetType = "autosnippet",
			condition = tex.in_text * line_begin,
		},
		{
			t({ "\\begin{itemize}", "\t\\item " }),
			i(1),
			d(2, rec_item, {}),
			t({ "", "\\end{itemize}" }),
		}
	),
	s(
		{
			trig = "\\?enn",
			dscr = "orderdered list",
			regTrig = true,
			snippetType = "autosnippet",
			condition = tex.in_text * line_begin,
		},
		{
			t({ "\\begin{enumerate}", "\t\\item " }),
			i(1),
			d(2, rec_item, {}),
			t({ "", "\\end{enumerate}" }),
		}
	),
}
