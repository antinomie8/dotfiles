-- Switch to header files using gf
vim.opt_local.suffixesadd:append({ ".h" })

-- debugging
require("utils.debugging").setup({
	"clang",
	"-g",
	"-O0",
	"-lm",
	"-std=c23",
})
