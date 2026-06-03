return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>fmt",
			function()
				require("conform").format({ async = true }, function(err)
					if not err then
						local mode = vim.api.nvim_get_mode().mode
						if vim.startswith(string.lower(mode), "v") then
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
						end
					end
				end)
			end,
			mode = { "n", "v" },
			desc = "Format file or range (in visual mode)",
		},
	},
	init = function()
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting for all buffers
				vim.g.disable_autoformat = true
			else
				vim.b.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
	opts = function()
		local nvim_config = vim.fn.stdpath("config") .. "/"
		local zsh_config = (vim.env.ZDOTDIR or vim.env.HOME .. "/.zsh") .. "/"
		local disabled_paths = {
			nvim_config .. "lua/config/options.lua",
			nvim_config .. "lua/plugins/coding/dial.lua",
			nvim_config .. "lua/plugins/coding/surround.lua",
			nvim_config .. "lua/plugins/ui/dashboard.lua",
			nvim_config .. "lua/static/**/*.lua",
			nvim_config .. "after/plugin/icons.lua",
			nvim_config .. "after/queries/asymptote/highlights.scm",
			nvim_config .. "after/queries/typst/highlights.scm",

			zsh_config .. ".zshrc",
			zsh_config .. "config/keybinds.zsh",
			zsh_config .. "config/completions.zsh",

			(vim.env.TEXMFHOME or vim.env.HOME) .. "/tex/latex/**/*.tex",
			(vim.env.ASYMPTOTE_HOME or vim.env.HOME .. "/.asy") .. "/config.asy",
			(vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config") .. "/quickshell/ii/**",
		}
		local forbidden = {}
		for _, glob in ipairs(disabled_paths) do
			table.insert(forbidden, vim.glob.to_lpeg(glob))
		end

		return {
			formatters_by_ft = {
				asymptote = { "clang_format", "asymptote" },
				cpp = { "clang_format" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
				bash = { "shfmt" },
				fish = { "fish_indent", "spaces_to_tabs" },
				css = { "biome" },
				html = { "biome" },
				python = { "ruff_format" },
				tex = { "latex_math", "tex-fmt" },
				typst = { "typstyle", "spaces_to_tabs" },
				query = { "spaces_to_tabs", lsp_format = "first" },
				lua = function(bufnr)
					if
						vim.fs.root(
							vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
							{ "stylua.toml", ".stylua.toml" }
						)
					then
						return { "stylua" }
					else
						return { "lua_align", lsp_format = "first" }
					end
				end,
			},
			formatters = {
				clang_format = {
					prepend_args = function(_, ctx)
						local args = { "-assume-filename", "$FILENAME" }
						if vim.fs.root(ctx.buf, { ".clang-format", "_clang-format" }) == nil then
							table.insert(args,
								"--style=file:" ..
								(vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/clang-format/config.yaml"
							)
						end
						return args
					end,
				},
				typstyle = {
					prepend_args = { "--line-width", "100" },
				},
				shfmt = {
					prepend_args = function(_, ctx)
						local has_editorconfig = vim.fs.root(ctx.buf, ".editorconfig") ~= nil
						if not has_editorconfig then
							return { "--case-indent" }
						end
					end,
				},
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end

				local buf = vim.api.nvim_buf_get_name(bufnr)
				for _, pattern in ipairs(forbidden) do
					if pattern:match(buf) then
						return
					end
				end

				local formatters = require("conform").list_formatters_to_run(bufnr)
				if formatters == {} then
					return { timeout_ms = 700, lsp_format = "prefer" }
				else
					return { timeout_ms = 700 }
				end
			end,
		}
	end,
}
