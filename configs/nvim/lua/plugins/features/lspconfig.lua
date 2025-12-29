local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"rachartier/tiny-inline-diagnostic.nvim",
				opts = {},
			},
		},
		config = function()
			vim.lsp.config("*", {
				capabilities = {
					textDocument = {
						completionItem = {
							snippetSupprt = true,
						},
					},
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
			})

			local lspconfigs = {
				asm_lsp = {},

				asy_ls = {
					cmd = { "asy", "-lsp" },
					filetypes = { "asy" },
					root_markers = { ".git", ".latexmkrc" },
					single_file_support = true,
					settings = {},
				},

				bashls = {
					filetypes = { "bash", "sh", "zsh" },
				},

				clangd = {},

				cmake = {},

				cssls = {
					filetypes = { "html", "css", "scss" },
				},

				jsonls = {
					settings = {
						json = {
							schemas = function()
								local ok, schemas = pcall(require("schemastore").json.schemas())
								if ok then
									return schemas
								else
									return nil
								end
							end,
							validate = { enable = true },
						},
					},
				},

				lua_ls = {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								not (vim.fn.getcwd():match("nvim"))
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								-- Tell the language server which version of Lua you"re using
								version = "LuaJIT",
							},
							-- Make the server aware of Neovim runtime files
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
									"${3rd}/luv/library",
									-- "${3rd}/busted/library",
								},
							},
						})
					end,
					settings = {
						Lua = {
							format = {
								defaultConfig = {
									continuation_indent_size = "1",
									quote_style = "double",
									continuation_indent = "2", -- match indentwidth
									max_line_length = "120",
									table_separator_style = "comma",
									trailing_table_separator = "smart",
									call_arg_parentheses = "always",
									align_function_params = "true",
									align_continuous_assign_statement = "false",
									align_continuous_rect_table_field = "false",
									align_continuous_line_space = "2",
									align_if_branch = "false",
									align_array_table = "false",
									align_continuous_similar_call_args = "false",
									align_continuous_inline_comment = "true",
									align_chain_expr = "none",
								},
							},
						},
					},
				},

				qmlls = {
					cmd = { "qmlls6" },
				},

				tinymist = {
					on_init = function() vim.api.nvim_set_hl(0, "@lsp.type.comment.typst", { fg = "none", bg = "none" }) end,

					settings = {
						exportPdf = "onType",
						lint = {
							enabled = true,
						},
					},
					on_attach = function(client, bufnr)
						require("lspconfig.configs.tinymist").default_config.on_attach(client, bufnr)
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
					end,
				},

				yamlls = {
					settings = {
						yaml = {
							schemaStore = {
								enable = false,
								url = "",
							},
							schemas = function()
								local ok, schemas = pcall(require("schemastore").json.schemas())
								if ok then
									return schemas
								else
									return nil
								end
							end,
						},
					},
				},
			}

			for server, config in pairs(lspconfigs) do
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client:supports_method("textDocument/foldingRange") then
						local win = vim.api.nvim_get_current_win()
						vim.wo[win][0].foldmethod = "expr"
						vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
					end
					vim.lsp.document_color.enable(false, args.buf)
				end,
			})

			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
			vim.keymap.set("n", "<leader>doc", vim.lsp.buf.hover, { desc = "Hover documentation" })
			vim.keymap.set("n", "<leader>def", vim.lsp.buf.definition, { desc = "Go to definition" })
			vim.keymap.set("n", "<leader>dec", vim.lsp.buf.declaration, { desc = "Go to declaration" })
			vim.keymap.set("n", "<leader>ref", vim.lsp.buf.references, { desc = "References" })
			vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help" })
			-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
		end,
	},
	{
		"rmagatti/goto-preview",
		keys = {
			{ "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Preview definition" },
			{ "gpc", function() require("goto-preview").goto_preview_declaration() end, desc = "Preview declaration" },
			{ "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview implementation" },
			{ "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Preview references" },
			{
				"gpt",
				function() require("goto-preview").goto_preview_type_definition() end,
				desc = "Preview type definition",
			},
			{ "gpx", function() require("goto-preview").close_all_win() end, desc = "Close all previews" },
			{
				"gpX",
				function() require("goto-preview").close_all_win({ skip_curr_window = true }) end,
				desc = "Close other previews",
			},
		},
		opts = {
			width = 120, -- Width of the floating window
			height = 15, -- Height of the floating window
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- Border characters of the floating window
			opacity = 20, -- 0-100 opacity level of the floating window where 100 is fully transparent.
			resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
			post_open_hook = function() vim.keymap.set("n", "<esc>", "<Cmd>quit<CR>", { buffer = true }) end,
			focus_on_open = true, -- Focus the floating window when opening it.
			dismiss_on_move = false, -- Dismiss the floating window when moving the cursor.
			force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
			bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
			stack_floating_preview_windows = true, -- Whether to nest floating windows
			same_file_float_preview = true, -- Whether to open a new floating window for a reference within the current file
			preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
			zindex = 1, -- Starting zindex for the stack of floating windows
		},
	},
	{
		"rachartier/tiny-code-action.nvim",
		-- dependencies:
		--  nvim-telescope/telescope.nvim
		--  nvim-lua/plenary.nvim
		keys = {
			{
				"<leader>ca",
				function() require("tiny-code-action").code_action() end,
				desc = "Code actions",
				silent = true,
			},
		},
		opts = {
			backend = "delta",
			picker = "telescope",
			backend_opts = {
				delta = {
					header_lines_to_remove = 5,
				},
			},
			signs = {
				quickfix = { "", { link = "DiagnosticWarning" } },
				others = { "", { link = "DiagnosticWarning" } },
				refactor = { "", { link = "DiagnosticInfo" } },
				["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
				["refactor.extract"] = { "", { link = "DiagnosticError" } },
				["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
				["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
				["source"] = { "", { link = "DiagnosticError" } },
				["rename"] = { "", { link = "DiagnosticWarning" } },
				["codeAction"] = { "", { link = "DiagnosticWarning" } },
			},
		},
	},
	{
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		opts = {
			priority = 5, -- Priority of the lightbulb for all handlers except float.
			hide_in_unfocused_buffer = true,
			validate_config = "never",
			code_lenses = true,
			sign = { enabled = true, text = " ", lens_text = " " },
			virtual_text = { enabled = false, text = " ", lens_text = " ", pos = "eol" },
			float = {
				enabled = false,
				text = " ",
				lens_text = " ",
				win_opts = { focusable = false },
			},
			status_text = { enabled = true, text = " ", lens_text = " ", text_unavailable = "" },
			number = { enabled = false },
			line = { enabled = false },
			autocmd = { enabled = true },
			filter = function(client_name, code_action)
				local ignored_kinds = {
					["lua_ls"] = { "refactor.rewrite" },
				}
				return not vim.tbl_contains(ignored_kinds[client_name] or {}, code_action.kind)
			end,
		},
	},
}
