return {
	{
		"stevearc/aerial.nvim",
		keys = {
			{ "<leader>a", "<Cmd>AerialToggle!<CR>", desc = "Toggle code outline window" },
		},
		cmd = {
			"AerialToggle",
			"AerialOpen",
			"AerialOpenAll",
			"AerialClose",
			"AerialCloseAll",
			"AerialNext",
			"AerialPrev",
			"AerialGo",
			"AerialNavToggle",
			"AerialNavOpen",
			"AerialNavClose",
		},
		opts = function()
			local icons = require("static.icons").symbols
			icons.lua = { Package = icons.Control }

			local opts = {
				attach_mode = "global",
				backends = { "lsp", "treesitter", "markdown", "man" },
				show_guides = true,
				layout = {
					min_width = 20,
					resize_to_content = true,
					win_opts = {
						winhl = "Normal:NormalDark,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
						signcolumn = "no",
						statuscolumn = "",
					},
				},
				close_automatic_events = { "unsupported" },
				filter_kind = {
					"Class",
					"Constructor",
					"Enum",
					"Function",
					"Interface",
					"Module",
					"Method",
					"Struct",
				},
				icons = icons,
				manage_folds = true,
				link_folds_to_tree = true,
				link_tree_to_folds = true,
				guides = {
					mid_item = "├ ",
					last_item = "└ ",
					nested_top = "│ ",
					whitespace = "	",
				},
				ignore = {
					filetypes = { "alpha", "neo-tree", "CompetiTest", "toggleterm", "undotree" },
				},
			}
			return opts
		end,
	},
	{
		"Bekaboo/dropbar.nvim",
		lazy = false, -- this plugin lazy loads itself
		opts = function()
			local dropbar_api = require("dropbar.api")

			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })

			return {
				bar = {
					pick = {
						pivots = {
							"qsdfghjklmazertyuiopwxcvbn",
						},
					},
				},
				menu = {
					entry = {
						padding = { left = 0, right = 1 },
					},
					win_configs = {
						border = "rounded",
					},
					scrollbar = {
						enable = false,
					},
				},
				fzf = {
					prompt = "❯ ",
				},
				icons = {
					kinds = {
						symbols = require("static.icons").symbols,
					},
					ui = {
						menu = {
							indicator = "",
						},
					},
				},
				sources = {
					lsp = {
						valid_sources = {
							"array",
							"boolean",
							"break_statement",
							"call",
							"case_statement",
							"class",
							"constant",
							"constructor",
							"continue_statement",
							"delete",
							"do_statement",
							"element",
							"enum",
							"enum_member",
							"event",
							"for_statement",
							"function",
							"h1_marker",
							"h2_marker",
							"h3_marker",
							"h4_marker",
							"h5_marker",
							"h6_marker",
							"if_statement",
							"interface",
							"keyword",
							"macro",
							"method",
							"module",
							"namespace",
							"null",
							"number",
							"operator",
							"package",
							"pair",
							"property",
							"reference",
							"repeat",
							"rule_set",
							"scope",
							"specifier",
							"struct",
							"switch_statement",
							"type",
							"type_parameter",
							"unit",
							"value",
							"variable",
							"while_statement",
							"declaration",
							"field",
							"identifier",
							"object",
							"statement",
						},
					},
				},
			}
		end,
	},
}
