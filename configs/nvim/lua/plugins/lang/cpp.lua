return {
	"p00f/clangd_extensions.nvim",
	keys = {
		{
			"<localleader>f",
			"<Cmd>ClangdSwitchSourceHeader<CR>",
			ft = { "c", "cpp" },
			desc = "Switch between source and header files",
		},
	},
	cmd = {
		"ClangdSwitchSourceHeader",
		"ClangdAST",
		"ClangdSymbolInfo",
		"ClangdTypeHierarchy",
		"ClangdMemoryUsage",
	},
	opts = {
		ast = {
			role_icons = {
				type = " ",
				declaration = "󰙠 ",
				expression = " ",
				specifier = " ",
				statement = " ",
				["template argument"] = " ",
			},
			kind_icons = {
				Compound = "󰅩 ",
				Recovery = " ",
				TranslationUnit = " ", -- 
				PackExpansion = "󰪴 ", -- 
				TemplateTypeParm = "󰆩 ",
				TemplateTemplateParm = "󰆩 ",
				TemplateParamObject = "󰆩 ",
			},

			highlights = {
				detail = "Comment",
			},
		},
		memory_usage = {
			border = "rounded",
		},
		symbol_info = {
			border = "rounded",
		},
	},
}
