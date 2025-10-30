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

local function find_config_file(...)
	local arg = { ... }
	local function default()
		local config_file = arg[1]
		if config_file:sub(1, 1) == "." then
			config_file = config_file:sub(2, #config_file)
		end
		return (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/formatters/" .. config_file
	end
	return vim.fs.find(arg, {
		type = "file",
		upward = true,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
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
	opts = {
		formatters_by_ft = {
			asy = { "clang_format", "asy" },
			cpp = { "clang_format" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			css = { "prettier" },
			js = { "prettier" },
			tex = { "tex", "tex_fmt" },
			typst = { "typstyle" },

			["*"] = { "trim_whitespace", "trim_newlines" },
		},
		formatters = {
			clang_format = {
				command = "clang-format",
				args = function() return "--style=file:" .. find_config_file(".clang-format") end,
			},
			tex_fmt = {
				command = "tex-fmt",
				args = function()
					return {
						"--config",
						find_config_file("tex-fmt.toml"),
						"--stdin",
					}
				end,
			},
			stylua = {
				command = "stylua",
				prepend_args = function()
					return {
						"--config-path",
						find_config_file(".stylua.toml", "stylua.toml"),
					}
				end,
			},
			prettier = {
				command = "prettier",
				prepend_args = { "--use-tabs" },
			},
		},
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			local disabled_paths = {
				"^" .. vim.fn.stdpath("config") .. "/lua/config/options.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/plugins/coding/autopairs.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/static/.*.lua$",
				"^" .. vim.fn.stdpath("config") .. "/lua/statusline/components.lua$",
				"^" .. vim.fn.stdpath("config") .. "/after/ftplugin/typst/typst.lua$",
				"^" .. vim.fn.stdpath("config") .. "/snippets/.*%.lua$",

				"^" .. (vim.env.TEXMFHOME or vim.env.HOME) .. "/tex/latex.*%.tex$",
			}
			for _, path in ipairs(disabled_paths) do
				if vim.api.nvim_buf_get_name(0):match(path) then
					return
				end
			end

			return { timeout_ms = 700, lsp_format = "prefer" }
		end,
	},
}
