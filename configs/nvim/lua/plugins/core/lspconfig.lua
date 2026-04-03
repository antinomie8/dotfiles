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
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"rachartier/tiny-inline-diagnostic.nvim",
				opts = {
					options = {
						format = function(diagnostic)
							return diagnostic.message
						end,
					},
				},
			},
		},
		config = function()
			local lspconfigs = {
				asm_lsp = {
					on_attach = function(_, bufnr) vim.diagnostic.enable(false, { bufnr = bufnr }) end,
				},

				asy_ls = {
					cmd = { "asy", "-autoimport", "geometry", "-lsp" },
					filetypes = { "asymptote" },
					root_markers = { ".git", ".latexmkrc" },
					single_file_support = true,
					settings = {},
				},

				bashls = {
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
						local config = "nvim"
						local path = client.workspace_folders and client.workspace_folders[1].name or vim.api.nvim_buf_get_name(0)
						if vim.fs.root(path, { ".luarc.json", ".luarc.jsonc" }) then
							return
						end

						if path:match("^" .. vim.env.HOME .. "/.config/yazi") then
							config = "yazi"
						end

						local configs = {
							nvim = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									version = "LuaJIT",
									-- Tell the language server how to find Lua modules same way as Neovim
									-- (see `:h lua-module-load`)
									path = {
										"lua/?.lua",
										"lua/?/init.lua",
									},
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
							},
							yazi = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									version = "Lua 5.5",
									-- Tell the language server how to find Lua modules
									path = {
										"plugins/?.yazi/main.lua",
									},
								},
								workspace = {
									library = {
										"~/.config/yazi/plugins/types.yazi/",
									},
								},
								diagnostics = {
									globals = {
										"Status", "Header", "Tabs", "Linemode", "Entity",
									},
									disable = {
										"cast-local-type",
									},
								},
							},
						}

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, configs[config])
					end,
					settings = {
						Lua = {
							format = {
								defaultConfig = {
									continuation_indent = "5", -- modifying this will break ../../conform/formatters/lua_align.lua
									quote_style = "double",
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
									space_before_inline_comment = "keep",
								},
							},
							diagnostics = {
								disable = {
									"redefined-local",
									"unused-local",
								},
							},
						},
					},
				},

				rust_analyzer = {},

				tinymist = {
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
				},

				ts_query_ls = {
					init_options = {
						parser_aliases = {
							asymptote = "cpp",
						},
						valid_predicates = {
							in_asy = {
								parameters = {},
								description = "Check the current file is an asymptote file",
							},
						},
					},
				},

				ty = {}, -- python

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

			vim.schedule(function()
				for server, config in pairs(lspconfigs) do
					vim.lsp.config(server, config)
					vim.lsp.enable(server)
				end
			end)

			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
			vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help" })
			-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

			vim.keymap.set("n", "<leader>cpd", function()
				local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
				local diagnostics = vim.diagnostic.get(0, { lnum = lnum })

				if vim.tbl_isempty(diagnostics) then
					print("No diagnostics on this line")
					return
				end

				local lines = {}

				for _, d in ipairs(diagnostics) do
					-- Main diagnostic message
					table.insert(lines, d.message)

					-- Related information (if any)
					if d.user_data and d.user_data.lsp and d.user_data.lsp.relatedInformation then
						for _, info in ipairs(d.user_data.lsp.relatedInformation) do
							local uri = info.location.uri or ""
							local filename = vim.uri_to_fname(uri)
							local row = info.location.range.start.line + 1
							local col = info.location.range.start.character + 1

							table.insert(lines,
								string.format("  -> %s:%d:%d: %s", filename, row, col, info.message)
							)
						end
					end
				end

				local text = table.concat(lines, "\n")
				vim.fn.setreg("+", text)
				print("Diagnostic info copied to clipboard")
			end, { desc = "Copy diagnostics to clipboard" })

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client:supports_method("textDocument/foldingRange") then
						local win = vim.api.nvim_get_current_win()
						vim.wo[win][0].foldmethod = "expr"
						vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
					end
				end,
			})
			vim.lsp.document_color.enable(false)
		end,
	},
	{
		"rmagatti/goto-preview",
		keys = {
			{ "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Preview definition" },
			{ "gpc", function() require("goto-preview").goto_preview_declaration() end, desc = "Preview declaration" },
			{ "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview implementation" },
			{ "gpt", function() require("goto-preview").goto_preview_type_definition() end, desc = "Preview type definition" },
			{ "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Preview references" },
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
		--  nvim-lua/plenary.nvim
		--  folke/snacks.nvim
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
			picker = "snacks",
			backend_opts = {
				delta = {
					header_lines_to_remove = 5,
				},
			},
			signs = {
				["quickfix"] = { "", { link = "DiagnosticWarning" } },
				["others"] = { "", { link = "DiagnosticWarning" } },
				["refactor"] = { "", { link = "DiagnosticInfo" } },
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
	-- {
	-- 	"kosayoda/nvim-lightbulb",
	-- 	event = "LspAttach",
	-- 	opts = {
	-- 		priority = 5, -- Priority of the lightbulb for all handlers except float.
	-- 		hide_in_unfocused_buffer = true,
	-- 		validate_config = "never",
	-- 		code_lenses = true,
	-- 		sign = { enabled = true, text = " ", lens_text = " " },
	-- 		virtual_text = { enabled = false, text = " ", lens_text = " ", pos = "eol" },
	-- 		float = {
	-- 			enabled = false,
	-- 			text = " ",
	-- 			lens_text = " ",
	-- 			win_opts = { focusable = false },
	-- 		},
	-- 		status_text = { enabled = true, text = " ", lens_text = " ", text_unavailable = "" },
	-- 		number = { enabled = false },
	-- 		line = { enabled = false },
	-- 		autocmd = { enabled = true },
	-- 		filter = function(client_name, code_action)
	-- 			local ignored_kinds = {
	-- 				["lua_ls"] = { "refactor.rewrite" },
	-- 			}
	-- 			return not vim.tbl_contains(ignored_kinds[client_name] or {}, code_action.kind)
	-- 		end,
	-- 	},
	-- },
}
