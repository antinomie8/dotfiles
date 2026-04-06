vim.bo.includeexpr = "v:lua.require'utils.includeexpr'.typst()"
vim.b.current_compiler = "typst" -- disable default compiler in $VIMRUNTIME/compiler/typst.vim
vim.bo.makeprg = "typst compile --diagnostic-format short "
                 .. vim.fn.shellescape(vim.b.typst_root or vim.api.nvim_buf_get_name(0))

-- textobjects
vim.keymap.set({ "x", "o" }, "am", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@math.outer", "textobjects")
end, { buffer = true, desc = "outer math" })
vim.keymap.set({ "x", "o" }, "im", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@math.inner", "textobjects")
end, { buffer = true, desc = "inner math" })
