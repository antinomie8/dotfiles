-- debugging
require("utils.debugging").setup({
	"rustc",
	"-C",
	"debuginfo=2",
	"-C",
	"opt-level=0",
})
