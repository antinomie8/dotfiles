local M = {}

M.types = {
	kind = "Class",
	"void",
	"bool",
	"int",
	"real",
	"string",

	"pair",
	"triple",

	"path",
	"guide",

	"pen",
	"picture",
	"frame",
	"transform",

	"projection",

	-- geometry.asy
	"point",
	"line",
	"segment",
	"ray",
	"circle",
	"triangle",
}

M.constants = {
	kind = "Constant",
	"pi",
	"infinity",
	"currentpen",
	"currentpicture",
	"defaultpen",
	"linewidth",
	"fontsize",
}

M.draw = {
	kind = "Function",
	"draw",
	"fill",
	"filldraw",
	"clip",
	"label",
	"dot",

	"shipout",
	"erase",
	"add",

	"scale",
	"shift",
	"rotate",
	"reflect",

	"xscale",
	"yscale",

	"bbox",
}

M.paths = {
	kind = "Function",
	"point",
	"dir",
	"length",
	"arclength",
	"reverse",
	"subpath",

	"intersectionpoint",
	"intersectionpoints",

	"relpoint",
	"point",
	"prepoint",
	"postpoint",
}

M.mathf = {
	kind = "Function",
	"sin",
	"cos",
	"tan",
	"asin",
	"acos",
	"atan",
	"atan2",

	"sinh",
	"cosh",
	"tanh",

	"exp",
	"log",
	"sqrt",
	"pow",

	"abs",
	"floor",
	"ceil",
	"round",

	"min",
	"max",

	"random",
}

M.pen = {
	kind = "Color",
	"rgb",
	"cmyk",
	"gray",

	"red",
	"green",
	"blue",
	"black",
	"white",
	"yellow",
	"cyan",
	"magenta",

	"linewidth",
	"linetype",
	"dashed",
	"dotted",
}

M.graph = {
	kind = "Function",
	"graph",
	"plot",
	"function",
	"xaxis",
	"yaxis",
	"axes",
	"grid",

	"Log",
	"Linear",
}

M.geometry = {
	kind = "Function",
	-- constructors
	"line",
	"segment",
	"ray",
	"circle",
	-- "triangle",

	-- points
	"midpoint",
	"foot",
	"projection",
	"intersection",
	"intersectionpoints",

	-- triangle centers
	"centroid",
	"circumcenter",
	"incenter",
	"orthocenter",

	-- circle helpers
	"incircle",
	"circumcircle",

	-- relations
	"parallel",
	"perpendicular",
	"collinear",

	-- measurements
	"distance",
	"angle",

	-- transformations
	"reflect",
	"rotate",
	"translate",
}

M.util = {
	kind = "Function",
	"write",
	"read",
	"format",
	"size",
	"length",
}

return M
