local symbols = require("static.lang.typst.typst_symbols")

local custom = {
	["dot"]        = symbols["dot.c"],
	["dots"]       = symbols["dots.h"],
	["dots.c"]     = symbols["dots.h.c"],
	["tilde"]      = symbols["tilde.basic"],
	["star"]       = symbols["star.op"],
	["arrow"]      = { cchar = "->" , hl = "TypstConcealSymbol" },
	["arrow.long"] = { cchar = "-->" , hl = "TypstConcealSymbol" },

	["limits"]     = { cchar = "", hl = "TypstConcealSymbol" },
	["space"]      = { cchar = "space", hl = "Comment" },
	["quad"]       = { cchar = "quad", hl = "Comment" },
	["mod"]        = { cchar = "mod", hl = "Delimiter" },
	["dif"]        = { cchar = "d", hl = "Operator" },

	["pm"]         = symbols["plus.minus"],
	["mp"]         = symbols["minus.plus"],
	["iff"]        = symbols["arrow.l.r.double.long"],
	["tensor"]     = symbols["times.o"],
	["prod"]       = symbols["product"],
	["setminus"]   = symbols["without"],

	["sumcyc"]     = { cchar = "∑", hl = "TypstConcealSymbol" },
	["sumsym"]     = { cchar = "∑ₛₘ", hl = "TypstConcealSymbol" },
	["iRR"]        = { cchar = "iℝ", hl = "TypstConcealSet" },
	["ZpZ"]        = { cchar = "ℤ/pℤ", hl = "TypstConcealSet" },
	["ZnZ"]        = { cchar = "ℤ/nℤ", hl = "TypstConcealSet" },
}

return setmetatable(custom, {
	__index = function(_, key)
		return symbols[key]
	end
})
