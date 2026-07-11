local function get_node(ctx)
	local pos = { ctx.cursor.row - 1, ctx.cursor.col }
	return vim.treesitter.get_node({ bufnr = ctx.bufnr, pos = pos })
end

return {
	{
		"saghen/blink.pairs",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = "saghen/blink.lib",

		version = "*",
		-- download prebuilt binaries from github releases, must be on a versioned release
		build = function() require("blink.pairs").download():pwait(60000) end,
		-- OR build from source
		-- build = function() require('blink.pairs').build():pwait(60000) end,

		---@module 'blink.pairs'
		---@type blink.pairs.Config
		opts = {
			mappings = {
				-- you can call require("blink.pairs.mappings").enable()
				-- and require("blink.pairs.mappings").disable()
				-- to enable/disable mappings at runtime
				enabled = true,
				cmdline = true,
				-- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
				-- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
				disabled_filetypes = {
					"snacks_picker_input",
					"grug-far",
				},
				wrap = {
					["<C-b>"] = "motion",
					["<C-S-b>"] = "motion_reverse",
					["<M-e>"] = "treesitter",
					["<M-S-e>"] = "treesitter_reverse",
					-- normal_mode = {} <- for normal mode mappings, only supports 'motion' and 'motion_reverse'
				},
				-- see the defaults:
				-- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L52
				pairs = {
					["("] = {
						{
							")",
							when = function(ctx)
								if ctx.ts:is_language("cpp") then
									return not ctx:text_before_cursor():match("%Wall")
								elseif ctx.ts:is_language("latex") then
									return not vim.endswith(ctx:text_before_cursor(), "\\left")
								else
									return true
								end
							end,
						},
						{
							"\\(",
							"\\)",
							languages = { "latex" },
							when = function(ctx)
								return vim.endswith(ctx:text_before_cursor(), "\\(")
							end,
						},
					},
					["["] = {
						{
							"]",
							when = function(ctx)
								if vim.tbl_contains({ "bash", "zsh", "sh" }, ctx.ft) then
									-- LuaSnip if/while [[ | ]]; then snippet
									return not ctx:text_before_cursor():match("^%s*if ")
										and not ctx:text_before_cursor():match("^%s*while ")
								elseif ctx.ts:is_language("latex") then
									return not vim.endswith(ctx:text_before_cursor(), "\\left")
								else
									return true
								end
							end,
							space = function(ctx)
								return not ctx.ts:is_language("markdown")
									-- ignore markdown todo items (bullets and numbered)
									or (
										not ctx:text_before_cursor():match("^%s*[%*%-+]%s+%[%s*$")
										and not ctx:text_before_cursor():match("^%s*%d+%.%s+%[%s*$")
									)
							end,
						},
						-- { "[=[", "]=]", languages = { "lua" } },
						-- { "[==[", "]==]", languages = { "lua" } },
						-- { "[===[", "]===]", languages = { "lua" } },
					},
					["{"] = {
						{
							"}",
							when = function(ctx)
								return not ctx.ts:is_language("latex")
									or not vim.endswith(ctx:text_before_cursor(), "\\left")
							end,
						},
					},
					["*"] = {
						{
							"/*", "*/", languages = { "c", "cpp", "typst", "rust", "css", "go" }, priority = 10,
						},
						{
							"*",
							languages = { "typst" },
							-- close = BUG
							when = function(ctx)
								if ctx:text_before_cursor():match('^%s*#import%s*"[^"]*:"') then
									-- wildcard operator in imports
									return false
								else
									local node = get_node(ctx)
									return require("utils.treesitter").has_ancestor(
										node,
										{ "content", "source_file" },
										{ "code", "math", "string", "comment", "label", "formula" }
									)
								end
							end,
						},
						{
							"*",
							languages = { "markdown", "markdown_inline" },
							when = function(ctx)
								local node = get_node(ctx)
								return not require("utils.treesitter").has_ancestor(node,
										{ "latex_block", "code_span", "fenced_code_block", "ERROR" })
									and not ctx:text_before_cursor():match("%s*")
							end,
						},
						{
							"**",
							"**",
							when = function(ctx)
								return vim.endswith(ctx:text_before_cursor(), "*")
									and not require("utils.treesitter").has_ancestor(get_node(ctx),
										{ "latex_block", "code_span", "fenced_code_block", "ERROR" })
							end,
							languages = { "markdown", "markdown_inline" },
						},
					},
					["$"] = {
						{ "$", "$", languages = { "typst", "markdown", "markdown_inline", "plaintex" } },
						{
							"\\(",
							"\\)",
							languages = { "latex" },
							when = function(ctx)
								return not vim.endswith(ctx:text_before_cursor(), "\\")
							end,
						},
						{
							"$$",
							"$$",
							when = function(ctx)
								return vim.endswith(ctx:text_before_cursor(), "$")
							end,
							languages = { "markdown", "markdown_inline", "latex", "plaintex" },
						},
					},
					["£"] = {
						{ "\\[", "\\]", languages = { "latex" } },
					},
					["~"] = {
						{
							"~~",
							"~~",
							when = function(ctx)
								return vim.endswith(ctx:text_before_cursor(), "~")
							end,
							languages = { "markdown", "markdown_inline" },
						},
					},
					["<"] = {
						{ "<", ">", when = function(ctx) return ctx.ts:whitelist("angle").matches end, languages = { "rust" } },
						{
							">",
							languages = { "cpp" },
							when = function(ctx)
								-- pair for e.g. templates, but not for << and >> operators
								-- e.g. 'std::cout <|', should not pair but 'std::vector<|>' should
								return ctx:text_before_cursor():match("%a$") or (
								-- for backspace
									vim.endswith(ctx:text_before_cursor(), "<")
									and vim.startswith(ctx:text_after_cursor(), ">")
								)
							end,
							backspace = function(ctx)
								return vim.endswith(ctx:text_before_cursor(), "<")
									and vim.startswith(ctx:text_after_cursor(), ">")
							end,
						},
					},
					-- [">"] = {
					-- 	{
					-- 		"<Cmd> ",
					-- 		"<CR>",
					-- 		when = function(ctx)
					-- 			local node = get_node(ctx)
					-- 			return require("utils.treesitter").has_ancestor(node, { "string" })
					-- 		end,
					-- 		languages = { "lua" },
					-- 	},
					-- },
				},
			},
			highlights = {
				enabled = true,
				-- requires require('vim._core.ui2').enable({}), otherwise has no effect
				cmdline = true,
				-- set to { 'BlinkPairs' } to disable rainbow highlighting
				groups = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
				unmatched_group = "BlinkPairsUnmatched",

				-- highlights matching pairs under the cursor
				matchparen = {
					enabled = true,
					-- known issue where typing won't update matchparen highlight, disabled by default
					cmdline = false,
					-- also include pairs not on top of the cursor, but surrounding the cursor
					include_surrounding = false,
					group = "BlinkPairsMatchParen",
					priority = 250,
				},
			},
			debug = false,
		},
	},
	{
		"windwp/nvim-ts-autotag",
		ft = {
			"astro",
			"glimmer",
			"handlebars",
			"html",
			"javascript",
			"jsx",
			"liquid",
			"markdown",
			"php",
			"rescript",
			"svelte",
			"tsx",
			"twig",
			"typescript",
			"vue",
			"xml",
		},
		opts = {},
	},
}
