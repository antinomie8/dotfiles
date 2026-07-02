local symbols = require("static.lang.typst.typst_symbols")

local custom = {
	["dot"]      = { cchar = "·", hl = "TypstConcealSymbol" },
	["dots"]     = { cchar = "…", hl = "TypstConcealSymbol" },
	["dots.c"]   = { cchar = "⋯", hl = "TypstConcealSymbol" },
	["tilde"]    = { cchar = "∼", hl = "TypstConcealSymbol" },
	["star"]     = { cchar = "⋆", hl = "TypstConcealSymbol" },
	["limits"]   = { cchar = "",  hl = "TypstConcealSymbol" },
	["space"]    = { cchar = "space", hl = "Comment" },
	["quad"]     = { cchar = "quad", hl = "Comment" },
	["mod"]      = { cchar = "mod", hl = "Delimiter" },
	["dif"]      = { cchar = "d", hl = "Operator" },

	["pm"]       = { cchar = "±", hl = "TypstConcealSymbol" },
	["mp"]       = { cchar = "∓", hl = "TypstConcealSymbol" },
	["iff"]      = { cchar = "⟺", hl = "TypstConcealSymbol" },
	["prod"]     = { cchar = "∏", hl = "TypstConcealSymbol" },
	["sumcyc"]   = { cchar = "∑", hl = "TypstConcealSymbol" },
	["sumsym"]   = { cchar = "∑ₛₘ", hl = "TypstConcealSymbol" },
	["tensor"]   = { cchar = "⊗", hl = "TypstConcealSymbol" },
	["setminus"] = { cchar = "∖", hl = "TypstConcealSymbol" },
	["iRR"]      = { cchar = "iℝ", hl = "TypstConcealSet" },
	["ZpZ"]      = { cchar = "ℤ/pℤ", hl = "TypstConcealSet" },
	["ZnZ"]      = { cchar = "ℤ/nℤ", hl = "TypstConcealSet" },
}

return setmetatable(custom, {
	__index = function(_, key)
		return symbols[key]
	end
})
