return {
	on_attach = function(_, bufnr)
		vim.diagnostic.enable(false, { bufnr = bufnr })
	end,
}
