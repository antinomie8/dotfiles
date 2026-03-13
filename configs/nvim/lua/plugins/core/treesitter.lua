return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			vim.cmd.syntax("manual")

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(event)
					local buf = event.buf
					local lang = vim.treesitter.language.get_lang(event.match)
					local disabled = { "checkhealth", "tex", "plaintex", "notify" }
					local no_indentexpr = { "typst" }
					if not vim.tbl_contains(disabled, vim.bo[buf].filetype) then
						if pcall(vim.treesitter.start) and lang then
							if
								vim.wo[0][0].foldexpr ~= "v:lua.vim.lsp.foldexpr()" and
								vim.treesitter.query.get(lang, "folds")
							then
								vim.wo[0][0].foldmethod = "expr"
								vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
							end
							if vim.treesitter.query.get(lang, "indents") and not vim.tbl_contains(no_indentexpr, vim.bo[buf].filetype) then
								vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
							end
							return
						end
					end
					vim.bo[buf].syntax = "ON"
				end,
			})

			vim.treesitter.language.register("cpp", "asymptote")
			vim.treesitter.query.add_predicate("in_asy?", function(_, _, source)
				return vim.bo[source].filetype == "asymptote"
			end)

			vim.api.nvim_create_autocmd("User", {
				pattern = { "TSInstall", "TSUpdate" },
				callback = function()
					require("nvim-treesitter.parsers").tsqx = {
						install_info = {
							url = "https://github.com/extouchtriangle/tree-sitter-tsqx",
						},
					}
				end,
			})

			require("nvim-treesitter").install({
				"asm",
				"bash",
				"c",
				"cpp",
				"hyprlang",
				"kitty",
				"latex",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"typst",
				"vim",
				"vimdoc",
				"zsh",
			})
		end,
	},
	{
		"anonymousgrasshopper/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true, -- jump forward to textobject

					selection_modes = { -- "v": charwise, "V": linewise, "<C-v>": blockwise
						["@function.outer"] = "V",
						["@function.inner"] = "v",
						["@class.outer"] = "V",
						["@class.inner"] = "v",
						["@local.scope"] = "V",
					},
				},
				move = {
					set_jumps = true,
				},
			})

			local textobjects = {
				select = {
					keymaps = {
						["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
						["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
						["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
						["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

						["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
						["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

						["ab"] = { query = "@block.outer", desc = "Select outer part of a block" },
						["ib"] = { query = "@block.inner", desc = "Select inner part of a block" },

						["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
						["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

						["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
						["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

						["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
						["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

						["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
						["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

						["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },

						["a/"] = { query = "@comment.outer", desc = "Select outer part of a comment" },
						["i/"] = { query = "@comment.inner", desc = "Select inner part of a comment" },

						["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
					},
				},
				move = {
					goto_next_start = {
						["]f"] = { query = "@call.outer", desc = "Next function call start" },
						["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
						["]c"] = { query = "@class.outer", desc = "Next class start" },
						["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
						["]l"] = { query = "@loop.outer", desc = "Next loop start" },
						["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
						["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
						["]/"] = { query = "@comment.outer", desc = "Next comment start" },
					},
					goto_next_end = {
						["]F"] = { query = "@call.outer", desc = "Next function call end" },
						["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
						["]C"] = { query = "@class.outer", desc = "Next class end" },
						["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
						["]L"] = { query = "@loop.outer", desc = "Next loop end" },
						["]/"] = { query = "@comment.outer", desc = "Next comment end" },
					},
					goto_previous_start = {
						["[f"] = { query = "@call.outer", desc = "Previous function call start" },
						["[m"] = { query = "@function.outer", desc = "Previous method/function def start" },
						["[c"] = { query = "@comment.outer", desc = "Previous comment start" },
						["[i"] = { query = "@conditional.outer", desc = "Previous conditional start" },
						["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
					},
					goto_previous_end = {
						["[F"] = { query = "@call.outer", desc = "Previous function call end" },
						["[M"] = { query = "@function.outer", desc = "Previous method/function def end" },
						["[C"] = { query = "@class.outer", desc = "Previous class end" },
						["[I"] = { query = "@conditional.outer", desc = "Previous conditional end" },
						["[L"] = { query = "@loop.outer", desc = "Previous loop end" },
						["[/"] = { query = "@comment.outer", desc = "Previous comment end" },
					},
				},
				swap = {
					swap_previous = {
						["[p"] = { query = "@parameter.inner", desc = "Swap with previous paramater" },
					},
					swap_next = {
						["]p"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
					},
				},
				repeatable = {
					motions = {
						[";"] = { callback = ts_repeat_move.repeat_last_move, desc = "repeat" },
						["<M-;>"] = { callback = ts_repeat_move.repeat_last_move_opposite, desc = "repeat in the opposite sense" },
						["f"] = { callback = ts_repeat_move.builtin_f_expr, desc = "find", expr = true },
						["F"] = { callback = ts_repeat_move.builtin_F_expr, desc = "backwards find", expr = true },
						["t"] = { callback = ts_repeat_move.builtin_t_expr, desc = "to", expr = true },
						["T"] = { callback = ts_repeat_move.builtin_T_expr, desc = "backwards to", expr = true },
					},
				},
			}

			local treesitter = {
				select = {
					modes = { "x", "o" },
					keymaps = function(opts)
						require("nvim-treesitter-textobjects.select").select_textobject(
							opts.query,
							opts.query_group or "textobjects"
						)
					end,
				},
				move = {
					modes = { "n" },
					goto_next_start = function(opts)
						require("nvim-treesitter-textobjects.move").goto_next_start(opts.query, opts.query_group or "textobjects")
					end,
					goto_next_end = function(opts)
						require("nvim-treesitter-textobjects.move").goto_next_end(opts.query, opts.query_group or "textobjects")
					end,
					goto_previous_start = function(opts)
						require("nvim-treesitter-textobjects.move").goto_previous_start(
							opts.query,
							opts.query_group or "textobjects"
						)
					end,
					goto_previous_end = function(opts)
						require("nvim-treesitter-textobjects.move").goto_previous_end(opts.query, opts.query_group or "textobjects")
					end,
				},
				swap = {
					modes = { "n" },
					swap_previous = function(opts) require("nvim-treesitter-textobjects.swap").swap_previous(opts.query) end,
					swap_next = function(opts) require("nvim-treesitter-textobjects.swap").swap_next(opts.query) end,
				},
				repeatable = {
					modes = { "n", "x", "o" },
				},
			}

			for textobject, actions in pairs(textobjects) do
				for action, keymaps in pairs(actions) do
					for keymap, opts in pairs(keymaps) do
						vim.keymap.set(
							treesitter[textobject]["modes"],
							keymap,
							opts.callback and opts.callback or function() treesitter[textobject][action](opts) end,
							{ desc = opts.desc or "", expr = opts.expr or false }
						)
					end
				end
			end

			-- overrides
			if vim.bo.filetype == "typst" then
				vim.keymap.set({ "x", "o" }, "am", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@math.outer", "textobjects")
				end, { buffer = true, desc = "outer math" })
				vim.keymap.set({ "x", "o" }, "im", function()
					require("nvim-treesitter-textobjects.select").select_textobject("@math.inner", "textobjects")
				end, { buffer = true, desc = "inner math" })
			end
		end,
	},
}
