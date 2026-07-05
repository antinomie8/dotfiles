local ls = require("utils.snippets.luasnip")
local s, t = ls.s, ls.t
local helpers = require("utils.snippets.helpers")

local typst = {}
typst.in_math = helpers.in_node("math", { "string" })
typst.in_text = function() return not helpers.in_node("math")() end


local triggers = {
	[";a"] = "alpha",
	[";b"] = "beta",
	[";g"] = "gamma",
	[";G"] = "Gamma",
	[";d"] = "delta",
	[";D"] = "Delta",
	[";e"] = "epsilon",
	[";ve"] = "epsilon.alt",
	[";z"] = "zeta",
	[";h"] = "eta",
	[";o"] = "theta",
	[";vo"] = "vartheta",
	[";O"] = "Theta",
	[";k"] = "kappa",
	[";l"] = "lambda",
	[";L"] = "Lambda",
	[";m"] = "mu",
	[";n"] = "nu",
	[";x"] = "xi",
	[";X"] = "Xi",
	[";i"] = "pi",
	[";I"] = "Pi",
	[";r"] = "rho",
	[";s"] = "sigma",
	[";S"] = "Sigma",
	[";t"] = "tau",
	[";f"] = "phi",
	[";vf"] = "phi.alt",
	[";F"] = "Phi",
	[";c"] = "chi",
	[";p"] = "psi",
	[";P"] = "Psi",
	[";w"] = "omega",
	[";W"] = "Omega",
}

local snippets = {}

for trigger, greek in pairs(triggers) do
	table.insert(snippets,
		s({ trig = trigger, snippetType = "autosnippet" }, {
			t(greek),
		}, { condition = typst.in_math })
	)
	table.insert(snippets,
		s({ trig = trigger, snippetType = "autosnippet" }, {
			t("$" .. greek .. "$ "),
		}, { condition = typst.in_text })
	)
end

return snippets
