vim.g.rust_recommended_style = 0

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- debugging
require("utils.debugging").setup({
	"rustc",
	"-C",
	"debuginfo=2",
	"-C",
	"opt-level=0",
})
