return {
	settings = {
		exportPdf = "onType",
		lint = {
			enabled = true,
		},
	},
	on_attach = function(client, bufnr)
		local root_path = vim.b[bufnr].typst_root
		if not root_path then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 3, false)

			for _, line in ipairs(lines) do
				local typst_root = line:match("^//%s*typst%s+root:%s*(.*)%s*$")
				if typst_root then
					vim.b[bufnr].typst_root = typst_root
					root_path = typst_root
				end
			end
		end
		if not root_path or not vim.uv.fs_stat(root_path) then
			return
		end

		local root_buf = vim.fn.bufadd(root_path)
		vim.bo[root_buf].buflisted = false

		if client then
			client:exec_cmd({
				title = "pin",
				command = "tinymist.pinMain",
				arguments = { vim.api.nvim_buf_get_name(root_buf) },
			}, { bufnr = bufnr })
			client:exec_cmd({
				title = "exportpdf",
				command = "tinymist.exportPdf",
				arguments = { vim.api.nvim_buf_get_name(root_buf) },
			}, { bufnr = bufnr })
		end

		vim.keymap.set(
			"n",
			"<localleader>tp",
			function()
				client:exec_cmd({
					title = "pin",
					command = "tinymist.pinMain",
					arguments = { vim.api.nvim_buf_get_name(0) },
				}, { bufnr = bufnr })
			end,
			{ desc = "tinymist pin main" }
		)
		vim.keymap.set(
			"n",
			"<localleader>tu",
			function()
				client:exec_cmd({
					title = "unpin",
					command = "tinymist.pinMain",
					arguments = { vim.v.null },
				}, { bufnr = bufnr })
			end,
			{ desc = "tinymist unpin main" }
		)

		-- execute nvim-lspconfig's on_attach from ~/.local/share/nvim/site/pack/nvim-lspconfig/lsp/tinymist.lua
		dofile(vim.fn.stdpath("data") .. "/site/pack/nvim-lspconfig/lsp/tinymist.lua").on_attach(client, bufnr)
	end,
}
