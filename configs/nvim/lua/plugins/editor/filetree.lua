return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	keys = {
		{ "\\", "<Cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
	},
	cmd = {
		"Neotree",
	},
	-- dependencies:
	-- 	MunifTanjim/nui.nvim
	-- 	nvim-lua/plenary.nvim
	-- 	nvim-tree/nvim-web-devicons
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
			desc = "Start Neo-tree with directory",
			once = true,
			callback = function()
				if package.loaded["neo-tree"] then
					return
				else
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						require("neo-tree")
					end
				end
			end,
		})
	end,
	opts = function()
		return {
			close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
			popup_border_style = "rounded",
			enable_diagnostics = false,
			enable_git_status = true,
			enable_modified_markers = true,
			enable_opened_markers = false,
			enable_cursor_hijack = true,
			git_status_async = true,
			log_level = "error",
			open_files_do_not_replace_types = { "CompetiTest", "dap", "terminal", "Trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
			bind_to_cwd = true,
			sort_case_insensitive = false,
			sort_function = function(a, b)
				if a.type == b.type then
					return a.path:lower() < b.path:lower()
				else
					return a.type < b.type
				end
			end, -- this sorts files and directories descendantly
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indent = {
					indent_size = 2,
					padding = 1, -- extra padding on left hand side
					-- indent guides
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					-- expander config, needed for nesting files
					with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰷏",
					default = "",
				},
				modified = {
					symbol = "●",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = false,
				},
				git_status = {
					symbols = {
						-- Change type
						added = " ",
						modified = " ",
						deleted = "󱟃 ",
						renamed = " ",
						removed = " ",
						-- Status type
						untracked = "",
						ignored = " ",
						unstaged = "󰄱 ",
						staged = " ",
						conflict = " ",
					},
				},
				file_size = {
					enabled = true,
					required_width = 42,
				},
				type = {
					enabled = true,
					required_width = 54,
				},
				last_modified = {
					enabled = true,
					required_width = 75,
				},
				created = {
					enabled = true,
					required_width = 100,
				},
				symlink_target = {
					enabled = false,
				},
			},
			-- A list of functions, each representing a global custom command
			-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
			-- see `:h neo-tree-custom-commands-global`
			commands = {},
			window = {
				position = "left",
				width = 28,
				mapping_options = {
					nowait = true,
				},
				mappings = {
					["<2-LeftMouse>"] = "open_vsplit",
					["<CR>"] = "open",
					["<ESC>"] = "cancel", -- close preview or floating neo-tree window
					["P"] = {
						"toggle_preview",
						config = {
							use_float = true,
							use_image_nvim = true,
							title = "Preview",
						},
					},
					["l"] = "focus_preview",
					["-"] = "open_split",
					["|"] = "open_vsplit",
					["S"] = "", -- "split_with_window_picker",
					["s"] = "", -- "vsplit_with_window_picker",
					["t"] = "open_tabnew",
					["T"] = "open_tab_drop",
					["O"] = "open_drop",
					["w"] = "open_with_window_picker",
					["z"] = "close_node",
					["Z"] = "close_all_nodes",
					["C"] = "close_all_subnodes",
					["E"] = "expand_all_nodes",
					["a"] = {
						"add",
						-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
						-- some commands may take optional config options, see `:h neo-tree-mappings` for details
						config = {
							show_path = "none", -- "none", "relative", "absolute"
						},
					},
					["A"] = "add_directory", -- also accepts config.show_path option and supports BASH style brace expansion.
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = {
						"copy",
						config = {
							show_path = "relative", -- "none", "relative", "absolute"
						},
					},
					["m"] = {
						"move",
						config = {
							show_path = "relative", -- "none", "relative", "absolute"
						},
					},
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
					["i"] = "show_file_details",
				},
			},
			nesting_rules = {},
			filesystem = {
				components = {
					custom_icon = function(config, node, state)
						return require("utils.plugins.filetree").get_icon(config, node, state)
					end,
				},
				filtered_items = {
					visible = false, -- when true, they will just be displayed differently than normal items
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_by_name = {
						--"node_modules"
					},
					hide_by_pattern = { -- uses glob style patterns
						"*.log",
					},
					always_show = { ".zshrc", ".zshenv" }, -- remains visible even if other settings would normally hide it
					always_show_by_pattern = {},      -- uses glob style patterns
					never_show = {},                  -- remains hidden even if visible is toggled to true, this overrides always_show
					never_show_by_pattern = {         -- uses glob style patterns
						".git",
						"*.aux",
						"*.fls",
						"*.pre",
						"*.toc",
						"*.fdb_latexmk",
						"*.synctex*",
					},
				},
				follow_current_file = {
					enabled = false,                  -- This will find and focus the file in the active buffer every time
					-- the current file is changed while the tree is open.
					leave_dirs_open = false,          -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
				},
				group_empty_dirs = false,           -- when true, empty folders will be grouped together
				hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens neo-tree
				use_libuv_file_watcher = false,     -- This will use the OS level file watchers to detect changes
				-- instead of relying on nvim autocmd events.
				window = {
					mappings = {
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["h"] = "toggle_hidden",
						["/"] = "fuzzy_finder",
						["D"] = "fuzzy_finder_directory",
						["#"] = "fuzzy_sorter",
						["<C-D>"] = "fuzzy_sorter_directory",
						["f"] = "filter_on_submit",
						["<c-x>"] = "clear_filter",
						["[g"] = "prev_git_modified",
						["]g"] = "next_git_modified",
						["O"] = "system_open",
						["o"] = {
							"show_help",
							nowait = false,
							config = { title = "Order by", prefix_key = "o" },
						},
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["og"] = { "order_by_git_status", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
						["H"] = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" and node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							else
								require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
							end
						end,
						["L"] = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" then
								if not node:is_expanded() then
									require("neo-tree.sources.filesystem").toggle_directory(state, node)
								elseif node:has_children() then
									require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
								end
							end
						end,
					},
					fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
						["<down>"] = "move_cursor_down",
						["<C-n>"] = "move_cursor_down",
						["<up>"] = "move_cursor_up",
						["<C-p>"] = "move_cursor_up",
						-- ['<key>'] = function(state, scroll_padding) ... end,
					},
				},
				commands = {
					system_open = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						-- Linux: open file in default application
						vim.fn.jobstart({ "xdg-open", path }, { detach = true })
					end,
				},
				-- components = {
				-- harpoon_index = function(config, node, _)
				-- 	local harpoon_list = require("harpoon"):list()
				-- 	local path = node:get_id()
				-- 	local harpoon_key = vim.uv.cwd()

				-- 	for i, item in ipairs(harpoon_list.items) do
				-- 		local value = item.value
				-- 		if string.sub(item.value, 1, 1) ~= "/" then
				-- 			value = harpoon_key .. "/" .. item.value
				-- 		end

				-- 		if value == path then
				-- 			return {
				-- 				text = string.format(" ⥤ %d", i),
				-- 				highlight = config.highlight or "NeoTreeDirectoryIcon",
				-- 			}
				-- 		end
				-- 	end
				-- 	return {}
				-- end,
				-- },
				renderers = {
					file = {
						{ "custom_icon" },
						{ "name", use_git_status_colors = true },
						-- { "harpoon_index" },
						{ "diagnostics" },
						{ "git_status", highlight = "NeoTreeDimText" },
					},
				},
			},
			buffers = {
				group_empty_dirs = false,
				show_unloaded = true,
				window = {
					mappings = {
						["bd"] = "buffer_delete",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["o"] = {
							"show_help",
							nowait = false,
							config = { title = "Order by", prefix_key = "o" },
						},
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			git_status = {
				window = {
					position = "float",
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = {
							"show_help",
							nowait = false,
							config = { title = "Order by", prefix_key = "o" },
						},
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			event_handlers = {
				{
					event = "neo_tree_window_after_open",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
				{
					event = "neo_tree_window_after_close",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.keymap.set("n", "J", "5j", { desc = "Scroll 5 lines down", buffer = true })
						vim.keymap.set("n", "K", "5k", { desc = "Scroll 5 lines down", buffer = true })

						vim.wo.fillchars = "vert: ,horizup:─,horizdown:─,vertleft:│,vertright:│,verthoriz:┬"
						vim.opt_local.sidescrolloff = 0
						vim.wo.winhighlight = "Normal:NormalDark"
					end,
				},
				{
					event = "neo_tree_popup_buffer_enter",
					handler = function()
						if vim.api.nvim_get_mode()["mode"] == "i" then
							vim.cmd("hi Cursor blend=0")
						else
							vim.opt_local.sidescrolloff = 0
							vim.wo.winhighlight = "WinSeparator:NeoTreePopupWinSeparator"
							vim.cmd("hi Cursor blend=100")
						end
					end,
				},
				{
					event = "file_moved",
					handler = function(_) vim.cmd("hi Cursor blend=100") end,
				},
				{
					event = "file_deleted",
					handler = function(_) vim.cmd("hi Cursor blend=100") end,
				},
				{
					event = "file_renamed",
					handler = function(_) vim.cmd("hi Cursor blend=100") end,
				},
				{
					event = "file_moved",
					handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
				},
				{
					event = "file_renamed",
					handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
				},
				-- {
				--	 event = "file_open_requested",
				--	 handler = function() require("neo-tree.command").execute({ action = "close" }) end,
				-- },
			},
		}
	end,
}
