return {
	"anonymousgrasshopper/snacks.nvim",
	keys = {
		-- Quick access
		{ "<leader><space>", function() require("snacks.picker").smart() end, desc = "Smart Find Files" },
		{ "<leader>,", function() require("snacks.picker").buffers() end, desc = "Buffers" },
		{ "<leader>/", function() require("snacks.picker").grep() end, desc = "Grep" },
		{ "<leader>:", function() require("snacks.picker").command_history() end, desc = "Command History" },
		-- find
		{ "<leader>fb", function() require("snacks.picker").buffers() end, desc = "Buffers" },
		{ "<leader>ff", function() require("snacks.picker").files() end, desc = "Find Files" },
		{ "<leader>fg", function() require("snacks.picker").git_files() end, desc = "Find Git Files" },
		{ "<leader>fp", function() require("snacks.picker").projects() end, desc = "Projects" },
		{ "<leader>fr", function() require("snacks.picker").recent() end, desc = "Find Recent Files" },
		-- git
		{ "<leader>gb", function() require("snacks.picker").git_branches() end, desc = "Git Branches" },
		{ "<leader>gl", function() require("snacks.picker").git_log() end, desc = "Git Log" },
		{ "<leader>gL", function() require("snacks.picker").git_log_line() end, desc = "Git Log Line" },
		{ "<leader>gs", function() require("snacks.picker").git_status() end, desc = "Git Status" },
		{ "<leader>gS", function() require("snacks.picker").git_stash() end, desc = "Git Stash" },
		{ "<leader>gd", function() require("snacks.picker").git_diff() end, desc = "Git Diff (Hunks)" },
		{ "<leader>gf", function() require("snacks.picker").git_log_file() end, desc = "Git Log File" },
		-- gh
		{ "<leader>gi", function() require("snacks.picker").gh_issue() end, desc = "GitHub Issues (open)" },
		{ "<leader>gI", function() require("snacks.picker").gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
		{ "<leader>gp", function() require("snacks.picker").gh_pr() end, desc = "GitHub Pull Requests (open)" },
		{ "<leader>gP", function() require("snacks.picker").gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
		-- Grep
		{ "<leader>sb", function() require("snacks.picker").lines() end, desc = "Buffer Lines" },
		{ "<leader>sB", function() require("snacks.picker").grep_buffers() end, desc = "Grep Open Buffers" },
		{ "<leader>sg", function() require("snacks.picker").grep() end, desc = "Grep" },
		{ "<leader>sw", function() require("snacks.picker").grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
		-- search
		{ '<leader>s"', function() require("snacks.picker").registers() end, desc = "Registers" },
		-- { "<leader>sr", function() require("snacks.picker").registers() end, desc = "Registers" },
		{ "<leader>s/", function() require("snacks.picker").search_history() end, desc = "Search History" },
		{ "<leader>sa", function() require("snacks.picker").autocmds() end, desc = "Autocmds" },
		{ "<leader>sb", function() require("snacks.picker").lines() end, desc = "Buffer Lines" },
		{ "<leader>sc", function() require("snacks.picker").command_history() end, desc = "Command History" },
		{ "<leader>sC", function() require("snacks.picker").commands() end, desc = "Commands" },
		{ "<leader>sd", function() require("snacks.picker").diagnostics() end, desc = "Diagnostics" },
		{ "<leader>sD", function() require("snacks.picker").diagnostics_buffer() end, desc = "Buffer Diagnostics" },
		{ "<leader>sh", function() require("snacks.picker").help() end, desc = "Help Pages" },
		{ "<leader>sH", function() require("snacks.picker").highlights() end, desc = "Highlights" },
		{ "<leader>si", function() require("snacks.picker").icons() end, desc = "Icons" },
		{ "<leader>sj", function() require("snacks.picker").jumps() end, desc = "Jumps" },
		{ "<leader>sk", function() require("snacks.picker").keymaps() end, desc = "Keymaps" },
		{ "<leader>sl", function() require("snacks.picker").loclist() end, desc = "Location List" },
		{ "<leader>sm", function() require("snacks.picker").marks() end, desc = "Marks" },
		{ "<leader>sM", function() require("snacks.picker").man() end, desc = "Man Pages" },
		{ "<leader>sp", function() require("snacks.picker").lazy() end, desc = "Search for Plugin Spec" },
		{ "<leader>sq", function() require("snacks.picker").qflist() end, desc = "Quickfix List" },
		{ "<leader>sR", function() require("snacks.picker").resume() end, desc = "Resume" },
		{ "<leader>su", function() require("snacks.picker").undo() end, desc = "Undo History" },
		{ "<leader>uC", function() require("snacks.picker").colorschemes() end, desc = "Colorschemes" },
		{ "<leader>sn", function() require("snacks.picker").notifications() end, desc = "Notification History" },
		-- LSP
		{ "grd", function() require("snacks.picker").lsp_definitions() end, desc = "Goto Definition" },
		{ "grD", function() require("snacks.picker").lsp_declarations() end, desc = "Goto Declaration" },
		{ "grr", function() require("snacks.picker").lsp_references() end, nowait = true, desc = "References" },
		{ "gri", function() require("snacks.picker").lsp_implementations() end, desc = "Goto Implementation" },
		{ "grt", function() require("snacks.picker").lsp_type_definitions() end, desc = "Goto Type Definition" },
		{ "grc", function() require("snacks.picker").lsp_incoming_calls() end, desc = "Incoming Calls" },
		{ "gro", function() require("snacks.picker").lsp_outgoing_calls() end, desc = "Outgoing Calls" },
		{ "<leader>ss", function() require("snacks.picker").lsp_symbols() end, desc = "LSP Symbols" },
		{ "<leader>sS", function() require("snacks.picker").lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
		-- misc
		{ "<leader>Z", function() require("snacks.picker").zoxide() end, desc = "Zoxide" },
	},
	opts = {
		picker = {
			prompt = "❯ ", -- 
			sources = {
				files = {
					hidden = true,
				},
				grep = {
					hidden = true,
				},
			},
			focus = "input",
			show_delay = 5000,
			limit_live = 10000,
			layout = {
				cycle = true,
				preset = function()
					return vim.o.columns >= 120 and "telescope" or "vertical"
				end,
			},
			---@class snacks.picker.matcher.Config
			matcher = {
				fuzzy = true,      -- use fuzzy matching
				smartcase = true,  -- use smartcase
				ignorecase = true, -- use ignorecase
				sort_empty = false, -- sort results when the search string is empty
				filename_bonus = true, -- give bonus for matching file names (last part of the path)
				file_pos = true,   -- support patterns like `file:line:col` and `file:line`
				-- the bonusses below, possibly require string concatenation and path normalization,
				-- so this can have a performance impact for large lists and increase memory usage
				cwd_bonus = false, -- give bonus for matching files in the cwd
				frecency = true,   -- frecency bonus
				history_bonus = false, -- give more weight to chronological order
			},
			sort = {
				-- default sort is by score, text length and index
				fields = { "score:desc", "#text", "idx" },
			},
			ui_select = true, -- replace `vim.ui.select` with the snacks picker
			---@class snacks.picker.formatters.Config
			formatters = {
				text = {
					ft = nil, ---@type string? filetype for highlighting
				},
				file = {
					filename_first = false, -- display filename before the file path
					--- * left: truncate the beginning of the path
					--- * center: truncate the middle of the path
					--- * right: truncate the end of the path
					---@type "left"|"center"|"right"
					truncate = "center",
					min_width = 40,   -- minimum length of the truncated path
					filename_only = false, -- only show the filename
					icon_width = 2,   -- width of the icon (in characters)
					git_status_hl = true, -- use the git status highlight group for the filename
				},
				selected = {
					show_always = false, -- only show the selected column when there are multiple selections
					unselected = true, -- use the unselected icon for unselected items
				},
				severity = {
					icons = true, -- show severity icons
					level = false, -- show severity level
					---@type "left"|"right"
					pos = "left", -- position of the diagnostics
				},
			},
			---@class snacks.picker.previewers.Config
			previewers = {
				diff = {
					-- fancy: Snacks fancy diff (borders, multi-column line numbers, syntax highlighting)
					-- syntax: Neovim's built-in diff syntax highlighting
					-- terminal: external command (git's pager for git commands, `cmd` for other diffs)
					style = "fancy", ---@type "fancy"|"syntax"|"terminal"
					cmd = { "delta" }, -- example for using `delta` as the external diff command
					---@type vim.wo?|{} window options for the fancy diff preview window
					wo = {
						breakindent = true,
						wrap = true,
						linebreak = true,
						showbreak = "",
					},
				},
				git = {
					args = {}, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
				},
				file = {
					max_size = 1024 * 1024, -- 1MB
					max_line_length = 500, -- max line length
					ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
				},
				man_pager = "nvim +Man!", ---@type string? MANPAGER env to use for `man` preview
			},
			---@class snacks.picker.jump.Config
			jump = {
				jumplist = true, -- save the current position in the jumplist
				tagstack = false, -- save the current position in the tagstack
				reuse_win = false, -- reuse an existing window if the buffer is already open
				close = true,  -- close the picker when jumping/editing to a location (defaults to true)
				match = false, -- jump to the first match position. (useful for `lines`)
			},
			toggles = {
				follow = { icon = "", value = true },
				hidden = { icon = "󰘓", value = false },
				ignored = { icon = "", value = true },
				modified = { icon = "", value = true },
				regex = { icon = "", value = false },
			},
			win = {
				-- input window
				input = {
					keys = {
						-- ["<C-k>"] = actions.move_selection_previous,
						-- ["<C-j>"] = actions.move_selection_next,
						-- ["<C-Down>"] = actions.cycle_history_next,
						-- ["<C-Up>"] = actions.cycle_history_prev,
						-- ["<M-i>"] = function() vim.api.nvim_win_set_cursor(0, { 1, 0 }) end,
						-- ["<M-a>"] = function() vim.api.nvim_win_set_cursor(0, { 1, #vim.api.nvim_get_current_line() }) end,
						-- esc cancel mode = i ?
						["/"] = "toggle_focus",
						["<C-Down>"] = { "history_forward", mode = { "i", "n" } },
						["<C-Up>"] = { "history_back", mode = { "i", "n" } },
						["<C-c>"] = { "cancel", mode = "i" },
						["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
						["<CR>"] = { "confirm", mode = { "n", "i" } },
						["<Down>"] = { "list_down", mode = { "i", "n" } },
						["<Esc>"] = "cancel",
						["<S-CR>"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
						["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
						["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
						["<Up>"] = { "list_up", mode = { "i", "n" } },
						["<a-d>"] = { "inspect", mode = { "n", "i" } },
						["<a-f>"] = { "toggle_follow", mode = { "i", "n" } },
						["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
						["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },
						["<a-r>"] = { "toggle_regex", mode = { "i", "n" } },
						["<a-m>"] = { "toggle_maximize", mode = { "i", "n" } },
						["<a-p>"] = { "toggle_preview", mode = { "i", "n" } },
						["<a-w>"] = { "cycle_win", mode = { "i", "n" } },
						["<c-a>"] = { "select_all", mode = { "n", "i" } },
						["<c-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
						["<c-d>"] = { "list_scroll_down", mode = { "i", "n" } },
						["<c-f>"] = { "preview_scroll_down", mode = { "i", "n" } },
						["<c-g>"] = { "toggle_live", mode = { "i", "n" } },
						["<c-j>"] = { "list_down", mode = { "i", "n" } },
						["<c-k>"] = { "list_up", mode = { "i", "n" } },
						["<c-n>"] = { "list_down", mode = { "i", "n" } },
						["<c-p>"] = { "list_up", mode = { "i", "n" } },
						["<c-q>"] = { "qflist", mode = { "i", "n" } },
						["<c-s>"] = { "edit_split", mode = { "i", "n" } },
						["<c-t>"] = { "tab", mode = { "n", "i" } },
						["<c-u>"] = { "list_scroll_up", mode = { "i", "n" } },
						["<c-v>"] = { "edit_vsplit", mode = { "i", "n" } },
						["<c-r>#"] = { "insert_alt", mode = "i" },
						["<c-r>%"] = { "insert_filename", mode = "i" },
						["<c-r><c-a>"] = { "insert_cWORD", mode = "i" },
						["<c-r><c-f>"] = { "insert_file", mode = "i" },
						["<c-r><c-l>"] = { "insert_line", mode = "i" },
						["<c-r><c-p>"] = { "insert_file_full", mode = "i" },
						["<c-r><c-w>"] = { "insert_cword", mode = "i" },
						["<c-w>H"] = "layout_left",
						["<c-w>J"] = "layout_bottom",
						["<c-w>K"] = "layout_top",
						["<c-w>L"] = "layout_right",
						["?"] = "toggle_help_input",
						["G"] = "list_bottom",
						["gg"] = "list_top",
						["j"] = "list_down",
						["k"] = "list_up",
						["q"] = "cancel",
					},
				},
				-- result list window
				list = {
					keys = {
						["/"] = "toggle_focus",
						["<2-LeftMouse>"] = "confirm",
						["<CR>"] = "confirm",
						["<Down>"] = "list_down",
						["<Esc>"] = "cancel",
						["<S-CR>"] = { { "pick_win", "jump" } },
						["<S-Tab>"] = { "select_and_prev", mode = { "n", "x" } },
						["<Tab>"] = { "select_and_next", mode = { "n", "x" } },
						["<Up>"] = "list_up",
						["<a-d>"] = "inspect",
						["<a-f>"] = "toggle_follow",
						["<a-h>"] = "toggle_hidden",
						["<a-i>"] = "toggle_ignored",
						["<a-m>"] = "toggle_maximize",
						["<a-p>"] = "toggle_preview",
						["<a-w>"] = "cycle_win",
						["<c-a>"] = "select_all",
						["<c-b>"] = "preview_scroll_up",
						["<c-d>"] = "list_scroll_down",
						["<c-f>"] = "preview_scroll_down",
						["<c-j>"] = "list_down",
						["<c-k>"] = "list_up",
						["<c-n>"] = "list_down",
						["<c-p>"] = "list_up",
						["<c-q>"] = "qflist",
						["<c-g>"] = "print_path",
						["<c-s>"] = "edit_split",
						["<c-t>"] = "tab",
						["<c-u>"] = "list_scroll_up",
						["<c-v>"] = "edit_vsplit",
						["<c-w>H"] = "layout_left",
						["<c-w>J"] = "layout_bottom",
						["<c-w>K"] = "layout_top",
						["<c-w>L"] = "layout_right",
						["?"] = "toggle_help_list",
						["G"] = "list_bottom",
						["gg"] = "list_top",
						["i"] = "focus_input",
						["j"] = "list_down",
						["k"] = "list_up",
						["q"] = "cancel",
						["zb"] = "list_scroll_bottom",
						["zt"] = "list_scroll_top",
						["zz"] = "list_scroll_center",
					},
					wo = {
						conceallevel = 2,
						concealcursor = "nvc",
					},
				},
				-- preview window
				preview = {
					keys = {
						["<Esc>"] = "cancel",
						["q"] = "cancel",
						["i"] = "focus_input",
						["<a-w>"] = "cycle_win",
					},
				},
			},
			icons = {
				files = {
					enabled = true, -- show file icons
					dir = "󰉋 ",
					dir_open = "󰝰 ",
					file = "󰈔 ",
				},
				keymaps = {
					nowait = "󰓅 ",
				},
				tree = {
					vertical = "│ ",
					middle = "├╴",
					last = "└╴",
				},
				undo = {
					saved = " ",
				},
				ui = {
					live = "󰐰 ",
					hidden = "h",
					ignored = "i",
					follow = "f",
					selected = "● ", -- 󱓻 
					unselected = "○ ",
				},
				git = {
					enabled = true, -- show git icons
					commit = "󰜘 ", -- used by git log
					staged = "●", -- staged changes. always overrides the type icons
					added = "",
					deleted = "",
					ignored = " ",
					modified = "○",
					renamed = "",
					unmerged = " ",
					untracked = "?",
				},
				diagnostics = {
					Error = "󰅚 ",
					Warn = "󰀪 ",
					Hint = " ",
					Info = " ",
				},
				lsp = {
					unavailable = "",
					enabled = " ",
					disabled = " ",
					attached = "󰖩 ",
				},
				kinds = require("static.icons"),
			},
		},
	},
}
