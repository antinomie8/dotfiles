return {
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
						"inject-field",
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
}
