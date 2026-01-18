vim.b.current_compiler = "typst" -- disable default compiler in $VIMRUNTIME/compiler/typst.vim
vim.bo.makeprg = "typst compile --diagnostic-format short "
	.. vim.fn.shellescape(vim.b.typst_root or vim.api.nvim_buf_get_name(0))
