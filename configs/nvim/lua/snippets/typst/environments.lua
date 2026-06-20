local ls = require("utils.snippets.luasnip")
local s, t, d = ls.s, ls.t, ls.d
local helpers = require("utils.snippets.helpers")
local line_begin = helpers.line_begin
local get_visual = helpers.get_visual

local snippets = {
	s({ trig = "voc", dscr = "vocabulary" },
		{ t('#vocab("'), d(1, get_visual), t('")') }),
	s({ trig = "!V", dscr = "vocabulary", snippetType = "autosnippet" },
		{ t('#vocab("'), d(1, get_visual), t('")') }),
}

local envs = {
	"theorem",
	"lemma",
	"proof",
	"exercise",
	"remark",
	"definition",
	"notation",
	"solution",
	"algorithm",
}

local abbrs = {
	["theorem"] = "thm",
	["lemma"] = "lem",
	["corollary"] = "cor",
	["proposition"] = "prop",
	["exercise"] = "exer",
	["definition"] = "def",
	["solution"] = "sol",
	["algorithm"] = "algo",
}

for _, env in ipairs(envs) do
	table.insert(snippets, s(
		{
			trig = "!" .. env:sub(1, 1):upper(),
			dscr = env,
			snippetType = "autosnippet",
			cond = line_begin,
			hidden = true,
		},
		{
			t({ "#" .. env .. "[", "\t" }),
			d(1, get_visual),
			t({ "", "]" }),
		}
	))
end
for env, abbr in ipairs(abbrs) do
	table.insert(snippets, s(
		{
			trig = "!" .. abbr,
			dscr = env,
			snippetType = "autosnippet",
			cond = line_begin,
		},
		{
			t({ "#" .. env .. "[", "", "\t" }),
			d(1, get_visual),
			t({ "", "]" }),
		}
	))
end

return snippets
