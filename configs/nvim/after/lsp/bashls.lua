return {
	filetypes = { "bash", "sh", "zsh" },
	on_attach = function(client, bufnr)
		local ft = vim.bo[bufnr].filetype
		-- Disable shellcheck diagnostics for zsh
		if ft == "zsh" then
			if client.name == "bashls" then
				vim.diagnostic.enable(false, { bufnr = bufnr })
			end
		end
	end,
}
