return {
	cmd = { "bun", "/home/antoine/Téléchargements/git/AsyLsp/server/out/server.js", "--stdio" },
	filetypes = { "asymptote" },
	single_file_support = true,
	settings = {
		asymptote = {
			asyPath = "asy",
			searchPaths = {},
			autoimport = { "preamble", "geometry" },
		},
	},
	capabilities = {
		textDocument = {
			semanticTokens = {
				enable = false,
			},
		},
	},
}
