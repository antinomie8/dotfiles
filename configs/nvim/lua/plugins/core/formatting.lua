local function find_config_file(dirname, filenames)
	local function default()
		local config_file = type(filenames) == "table" and filenames[1] or filenames
		if config_file:sub(1, 1) == "." then
			config_file = config_file:sub(2)
		end
		return (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/formatters/" .. config_file
	end
	return vim.fs.find(filenames, {
		type = "file",
		upward = true,
		path = dirname,
	})[1] or default()
end

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
	opts = {
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
				command = "clang-format",
				args = function(_, ctx)
					return {
						"-assume-filename", "$FILENAME",
						"--style=file:" .. find_config_file(ctx.dirname, { ".clang-format", "_clang-format" }),
					}
				end,
				range_args = function(self, ctx)
					local util = require("conform.util")
					local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
					local length = end_offset - start_offset
					return {
						"-assume-filename",
						"$FILENAME",
						"--offset",
						tostring(start_offset),
						"--length",
						tostring(length),
					}
				end,
			},
			typstyle = {
				command = "typstyle",
				prepend_args = { "--line-width", "100" },
			},
			shfmt = {
				command = "shfmt",
				args = function(_, ctx)
					local args = { "-filename", "$FILENAME" }
					local has_editorconfig = vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1]
					                         ~= nil
					-- If there is an editorconfig, don't pass any args because shfmt will apply settings from there
					-- when no command line args are passed.
					if not has_editorconfig then
						if vim.bo[ctx.buf].expandtab then
							vim.list_extend(args, { "-i", ctx.shiftwidth })
						end
						vim.list_extend(args, { "--case-indent" })
					end
					return args
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

			local disabled_paths = {
				"^" .. vim.fn.stdpath("config") .. "/lua/config/options.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/plugins/coding/dial.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/plugins/coding/surround.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/plugins/ui/dashboard.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/static/.*.lua$",
				"^" .. vim.fn.stdpath("config") .. "/after/plugin/icons.lua$",
				"^" .. vim.fn.stdpath("config") .. "/queries/asymptote/highlights.scm$",
				"^" .. vim.fn.stdpath("config") .. "/queries/typst/highlights.scm$",

				"^" .. (vim.env.TEXMFHOME or vim.env.HOME) .. "/tex/latex.*%.tex$",
				"^" .. (vim.env.ASYMPTOTE_HOME or vim.env.HOME .. "/.asy") .. "/config.asy$",
				"^" .. (vim.env.ZDOTDIR or vim.env.HOME .. ".zsh") .. "/.zshrc$",
				"^" .. (vim.env.ZDOTDIR or vim.env.HOME .. ".zsh") .. "/config/keybinds.zsh$",
				"^" .. (vim.env.ZDOTDIR or vim.env.HOME .. ".zsh") .. "/config/completions.zsh$",
			}
			for _, path in ipairs(disabled_paths) do
				if vim.api.nvim_buf_get_name(0):match(path) then
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
	},
}
