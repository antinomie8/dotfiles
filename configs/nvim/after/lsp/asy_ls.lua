return {
	-- cmd = { "asy", "-lsp" },
	-- settings = {},

	cmd = { "bun", "/home/antoine/Téléchargements/git/AsyLsp/server/out/server.js", "--stdio" },
	settings = {
		asymptote = {
			asyPath = "asy",
			searchPaths = {},
			autoimport = { "preamble", "geometry" },
		},
	},
	on_attach = function(client)
		vim.lsp.semantic_tokens.enable(false, { client_id = client.id })
	end,

	filetypes = { "asymptote" },
	root_markers = { ".git", ".latexmkrc" },
	single_file_support = true,
}
