return {
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = function()
			local in_node = function(...)
				local nodes = { ... }
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
				local nodes = { ... }
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
				if in_node("math", "raw_span", "raw_blck", "string", "comment", "ERROR")(fn, obj, pair) then
					return false
				end
				local node = vim.treesitter.get_node({ pos = { obj.row - 1, obj.col - 1 } })
				if node and node:type() == "source_file" then
					-- HACK: sometimes the current position is just out of the edge of the node
					node = vim.treesitter.get_node({ pos = { obj.row - 1, obj.col - 2 } })
				end
				while node do
					if node:type() == "content" then
						return true
					elseif node:type() == "code" then
						return false
					end
					node = node:parent()
				end
				return true
			end

			local markdown = {}
			markdown.in_text = not_in_node("latex_block", "code_span", "fenced_code_block", "ERROR")

			return {
				filetype = {
					nft = {
						"snacks_picker_input",
						"grug-far",
					},
				},
				space2 = { enable = true }, -- symmetric space in pairs
				close = { enable = true }, -- use <M-)> to close open pairs
				fastwarp = {
					multi = true,
					{},
					{ faster = true, map = "<M-e>", cmap = "<M-e>" },
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
									-- if the two characters before the cursor are paired, don't remove them
									{
										key = "<bs>",
										ft = "*",
										pred = function()
											local pairs = { '""', "()", "[]", "{}", "''", "<>", "$$", "**", "~~", "``", "\\(\\)", "\\[\\]" }
											local buffer_text = line:sub(col - 2, col - 1)
											local next_char = line:sub(col, col) or ""
											for _, pair in ipairs(pairs) do
												-- sometimes ((|)) is sent as (()|), refusing to delete on backspace, so add extra condition
												-- it's needed anyways when pair:sub(1, 1) == pair:sub(2, 2)
												if buffer_text == pair and next_char ~= pair:sub(2, 2) then
													return false
												end
											end
											return true
										end,
									},
									-- snippets
									{ key = "*", ft = { "markdown", "tex" }, text = "\\left" },
									{ key = "[", ft = { "bash", "zsh", "sh" }, text = { "if ", "while " } }, -- use sh in case ft is wrong
									{ key = "(", ft = "cpp", regex = { { "%Wall", 4 } } },
								}
								for _, cond in ipairs(conds) do
									local key = #cond.key == 1 and cond.key or vim.api.nvim_replace_termcodes(cond.key, true, false, true)
									if key == "*" or key == obj.key then
										if
											vim.tbl_contains(table_convert(cond.ft), function(v)
												return v == "*" or v == ft
											end, { predicate = true })
										then
											if cond.text then
												for _, text in ipairs(table_convert(cond.text)) do
													local buffer_text = line:sub(col - #text, col - 1)
													if buffer_text == text then
														return false
													end
												end
											end
											if cond.regex then
												for _, regex in ipairs(cond.regex) do
													local pattern, length = regex[1], (regex[2] or #regex[1])
													local buffer_text = line:sub(col - length, col - 1)
													if buffer_text:match("^" .. pattern .. "$") then
														return false
													end
												end
											end
											if cond.pred and not cond.pred() then
												return false
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
				{
					"<",
					">",
					cond = function(_, obj)
						if not obj then return false end
						local line, col = obj.line, obj.col
						if obj.key == vim.api.nvim_replace_termcodes("<bs>", true, true, true) then
							-- for some reason the <> is sometimes preceded by another char
							return line:sub(col - 1, col + 1):match("<>$") -- do not remove brackets unless they're next to each other
						elseif obj.key == "<" then -- do not pair if not next to text ( e.g. 'std::cout <|', but 'std::vector<|>' )
							return line:sub(col - 1, col):match("%w")
						end
						return true
					end,
				},
				-- comments
				{ "/*", "*/", ft = { "c", "cpp", "css", "go" }, newline = true, space = true },
				-- shell
				{ "[[", "]]", ft = { "bash", "zsh", "sh", "markdown" } },
				-- lua
				{ "[[", "]]", ft = { "lua" }, newline = true },
				{ "[=[", "]=]", ft = { "lua" }, newline = true },
				{ "[==[", "]==]", ft = { "lua" }, newline = true },
				{ "[===[", "]===]", ft = { "lua" }, newline = true },
				{ "<Cmd>", "<CR>", ft = { "lua" } },
				-- LaTeX
				{ "\\[", "\\]", ft = { "tex" }, disable_end = true, newline = true },
				{ "\\(", "\\)", ft = { "tex" }, disable_end = true, newline = true },
				-- typst
				{ "$", "$", ft = { "typst" }, cond = typst.in_text, space = true, newline = true },
				{ "```", "```", ft = { "typst" }, cond = typst.in_text, space = true, newline = true },
				{ "`", "`", ft = { "typst" }, cond = typst.in_text, space = true },
				{ "/*", "*/", ft = { "typst" }, cond = typst.in_text, newline = true },
				{ "_", "_", ft = { "typst" }, cond = typst.in_text },
				{ "*", "*", ft = { "typst" }, cond = function(fn, obj, pair) return typst.in_text(fn, obj, pair) and true end },
				--markdown
				{ "$", "$", ft = { "markdown" }, cond = markdown.in_text },
				{ "$$", "$$", ft = { "markdown" }, cond = markdown.in_text, newline = true },
				{ "*", "*", ft = { "markdown" }, cond = markdown.in_text },
				{ "**", "**", ft = { "markdown" }, cond = markdown.in_text },
				{ "~~", "~~", ft = { "markdown" }, cond = markdown.in_text },
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
