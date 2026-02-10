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
				require("conform").format({
					async = true,
				})
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
			asy = { "clang_format", "asy" },
			cpp = { "clang_format" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			zsh = { "shfmt" },
			bash = { "shfmt" },
			css = { "prettier" },
			js = { "prettier" },
			tex = { "tex", "tex_fmt" },
			typst = { "typstyle" },
			lua = function(bufnr)
				if
					#vim.fs.find({ "stylua.toml", ".stylua.toml" }, {
						type = "file",
						upward = true,
						path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
					}) > 0
				then
					return { "stylua" }
				else
					return { "lua_align", lsp_format = "first" }
				end
			end,

			["*"] = { "trim_newlines" },
			["_"] = { "trim_whitespace" },
		},
		formatters = {
			clang_format = {
				command = "clang-format",
				args = function(_, ctx)
					return "--style=file:" .. find_config_file(ctx.dirname, ".clang-format")
				end,
			},
			rustfmt = {
				command = "rustfmt",
				args = function(_, ctx)
					return {
						"--config-path",
						find_config_file(ctx.dirname, { "rustfmt.toml", ".rustfmt.toml" }),
					}
				end,
			},
			tex_fmt = {
				command = "tex-fmt",
				args = function(_, ctx)
					return {
						"--config",
						find_config_file(ctx.dirname, "tex-fmt.toml"),
						"--stdin",
					}
				end,
			},
			stylua = {
				command = "stylua",
				prepend_args = function(_, ctx)
					return {
						"--config-path",
						find_config_file(ctx.dirname, { "stylua.toml", ".stylua.toml" }),
					}
				end,
			},
			prettier = {
				command = "prettier",
				prepend_args = { "--use-tabs" },
			},
			typstyle = {
				command = "typstyle",
				prepend_args = { "--line-width", "100" },
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
				"^" .. vim.fn.stdpath("config") .. "/lua/plugins/ui/dashboard.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/static/.*.lua$",
				"^" .. vim.fn.stdpath("config") .. "/after/plugin/icons.lua$",

				"^" .. (vim.env.TEXMFHOME or vim.env.HOME) .. "/tex/latex.*%.tex$",
			}
			for _, path in ipairs(disabled_paths) do
				if vim.api.nvim_buf_get_name(0):match(path) then
					return
				end
			end

			return { timeout_ms = 700 }
		end,
	},
}
