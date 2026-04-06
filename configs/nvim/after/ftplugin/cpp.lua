-- Switch to header files using gf
vim.opt_local.suffixesadd:append({ ".h", ".hpp", ".cppm" })
vim.opt_local.path:append({ "include", vim.env.CPLUS_INCLUDE_PATH })

-- debugging
require("utils.debugging").setup({
	"clang++",
	"-g",
	"-O0",
	"-std=c++23",
})

-- compile and run SFML programs
vim.keymap.set("n", "<localleader>sf", function()
	vim.system({ "compile_sfml", vim.fn.expand("%:p:r") })
end, { expr = true, buffer = true })
