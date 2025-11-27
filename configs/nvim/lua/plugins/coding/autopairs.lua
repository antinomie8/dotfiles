return {
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = function()
			local on_bs_check_pattern = function(match_length, pattern)
				return function(_, obj)
					if not obj then return false end
					if obj.key == vim.api.nvim_replace_termcodes("<bs>", true, false, true) then
						local line, col = obj.line, obj.col
						if line:sub(col - match_length, col):match(pattern) then
							return false
						end
					end
					return true
				end
			end

			local in_node = function(...)
				local nodes = {...}
				return function(fn, obj, pair)
					if not obj then return true end
					if obj.key == vim.api.nvim_replace_termcodes(pair.pair, true, false, true) then
						return fn.in_node(nodes)
					else
						return false
					end
				end
			end
			local not_in_node = function(...)
				local nodes = {...}
				return function(fn, obj, pair)
					if not obj then return false end
					if obj.key == vim.api.nvim_replace_termcodes(pair.pair, true, false, true) then
						return not fn.in_node(nodes)
					else
						return true
					end
				end
			end

			local typst = {}
			typst.in_text = function(fn, obj, pair)
				return not_in_node("math", "raw_span", "raw_blck", "string", "comment")(fn, obj, pair)
			end
			typst.not_import = function(_, obj) return not obj.line:match("^%s*#import") end

			local markdown = {}
			markdown.in_text = not_in_node("math", "raw_span", "raw_blck", "string", "code", "comment")

			return {
				filetype = {
					nft = {
						"TelescopePrompt",
						"grug-far",
					},
				},
				space2 = { enable = true }, -- symmetric space in pairs
				close = { enable = true }, -- use <A-)> to close open pairs
				fastwarp = {
					multi = true,
					{},
					{ faster = true, map = "<A-e>", cmap = "<A-e>" },
				},
				extensions = {
					utf8 = false, -- see https://github.com/altermo/ultimate-autopair.nvim/issues/74
					fly = {
						only_jump_end_pair = true,
					},
					cond = {
						cond = {
							function(fn, obj)
								if fn.get_mode() == "R" then -- disable in replace mode
									return false
								end
								local line, col, ft = obj.line, obj.col, fn.get_ft()
								local function table_convert(arg) return type(arg) == "table" and arg or { arg } end
								local conds = {
									{
										"<bs>",
										"*",
										col - 2,
										{ '""', "()", "[]", "{}", "''", "<>", "$$", "**", "~~", "``" },
									}, -- if the two characters before the cursor are paired, don't remove them
									-- snippets
									{ "*", { "markdown", "tex" }, col - 6, "\\left" },
									{ "[", { "bash", "zsh", "sh" }, 1, { "if%s+$", "while%s+$" }, regex = true },
									{ "(", "cpp", col - 5, "%Wall", regex = true },
									{ "(", "lua", col - 9, "function" },
								}
								for _, cond in ipairs(conds) do
									local key = #cond[1] == 1 and cond[1] or vim.api.nvim_replace_termcodes(cond[1], true, false, true)
									if key == "*" or key == obj.key then
										if
											vim.tbl_contains(table_convert(cond[2]), function(v)
												return v == "*" or v == ft
											end, { predicate = true })
										then
											local start, stop = table_convert(cond[3])[1], table_convert(cond[3])[2] or col - 1
											local text = line:sub(start, stop)
											local patterns = table_convert(cond[4])
											for _, pattern in ipairs(patterns) do
												if cond.regex and text:match("^" .. pattern .. "$") or text == pattern then
													return false
												end
											end
										end
									end
								end

								return true
							end,
						},
					},
				},
				config_internal_pairs = {
					{ '"', '"', suround = false },
					{ "'", "'", suround = false },
				},
				{ "<", ">", disable_start = true, cond = on_bs_check_pattern(1, "^<[^>]?$") },
				-- comments
				{ "/*",    "*/",    ft = { "c", "cpp", "css", "go" }, newline = true, space = true },
				-- shell
				{ "[[", "]]", ft = { "bash", "zsh", "sh", "markdown" } },
				-- lua
				{ "[[",   "]]",     ft = { "lua" }, newline = true },
				{ "[=[",   "]=]",   ft = { "lua" }, newline = true },
				{ "[==[",  "]==]",  ft = { "lua" }, newline = true },
				{ "[===[", "]===]", ft = { "lua" }, newline = true },
				-- LaTeX
				{ "\\[", "\\]", ft = { "tex" }, disable_end = true, newline = true, cond = on_bs_check_pattern(4, "\\(\\)") },
				{ "\\(", "\\)", ft = { "tex" }, disable_end = true, newline = true, cond = on_bs_check_pattern(4, "\\[\\]" ) },
				-- typst
				{ "$", "$",     ft = { "typst" }, cond = typst.in_text, space = true, newline = true },
				{ "```", "```", ft = { "typst" }, cond = typst.in_text, space = true, newline = true },
				{ "`", "`",     ft = { "typst" }, cond = typst.in_text, space = true },
				{ "/*", "*/",   ft = { "typst" }, cond = typst.in_text, newline = true },
				{ "_", "_",     ft = { "typst" }, cond = typst.in_text },
				{ "*", "*",     ft = { "typst" }, cond = function(fn, obj, pair) return typst.in_text(fn, obj, pair) and typst.not_import(fn, obj) end },
				--markdown
				{ "$", "$",     ft = { "markdown" }, cond = markdown.in_text },
				{ "$$", "$$",   ft = { "markdown" }, cond = markdown.in_text, newline = true },
				{ "*", "*",     ft = { "markdown" }, cond = markdown.in_text },
				{ "**", "**",   ft = { "markdown" }, cond = markdown.in_text },
				{ "~~", "~~",   ft = { "markdown" }, cond = markdown.in_text },
				{ "```", "```", ft = { "markdown" }, cond = markdown.in_text, newline = true },
			}
		end,
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
