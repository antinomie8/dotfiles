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
		opts = {
			attach_mode = "global",
			backends = { "lsp", "treesitter", "markdown", "man" },
			show_guides = true,
			layout = {
				min_width = 20,
				resize_to_content = true,
				win_opts = {
					winhl = "Normal:NormalDark,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
					sidescrolloff = 0,
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
			icons = require("static.icons").symbols,
			autojump = true,
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
				filetypes = { "dashboard", "neo-tree", "CompetiTest", "toggleterm", "undotree" },
			},
		},
	},
	{
		"Bekaboo/dropbar.nvim",
		lazy = false, -- this plugin lazy loads itself
		keys = {
			{ "<leader>;", function() require("dropbar.api").pick() end, desc = "Pick symbols in winbar" },
			{ "[;", function() require("dropbar.api").goto_context_start() end, desc = "Go to start of current context" },
			{ "];", function() require("dropbar.api").select_next_context() end, desc = "Select next context" },
		},
		opts = {
			bar = {
				enable = function(buf, win, _)
					buf = vim._resolve_bufnr(buf)
					if
						not vim.api.nvim_buf_is_valid(buf)
						or not vim.api.nvim_win_is_valid(win)
					then
						return false
					end

					if
						not vim.api.nvim_buf_is_valid(buf)
						or not vim.api.nvim_win_is_valid(win)
						or vim.fn.win_gettype(win) ~= ""
						or vim.wo[win].winbar ~= ""
						or vim.bo[buf].ft == "help"
					then
						return false
					end

					local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
					if stat and stat.size > 1024 * 1024 then
						return false
					end

					if vim.tbl_contains({ "terminal", "quickfix", "nofile" }, vim.bo[buf].buftype) then
						return false
					end

					return vim.bo[buf].ft == "markdown"
						or pcall(vim.treesitter.get_parser, buf)
						or not vim.tbl_isempty(vim.lsp.get_clients({
							bufnr = buf,
							method = "textDocument/documentSymbol",
						}))
				end,
				pick = {
					pivots = "qsdfghjklmazertyuiopwxcvbn",
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
		},
	},
}
