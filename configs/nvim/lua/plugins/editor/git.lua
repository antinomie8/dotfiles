return {
	{
		"tpope/vim-fugitive",
		cmd = {
			"Git",
			"Gedit",
			"Gsplit",
			"Gedit",
			"Gdiffsplit",
			"Gvdiffsplit",
			"Gedit",
			"Gread",
			"Gwrite",
			"Ggrep",
			"Glgrep",
			"GMove",
			"GRename",
			"GDelete",
			"GRemove",
			"GBrowse",
		},
		ft = { "git", "DiffviewFiles" }, -- for statusline component
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				-- Navigation
				vim.keymap.set("n", "]g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				vim.keymap.set("n", "[g", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)

				-- Actions
				vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
				vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })

				vim.keymap.set(
					"v",
					"<leader>gs",
					function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
					{ desc = "Stage the current line" }
				)
				vim.keymap.set(
					"v",
					"<leader>gr",
					function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
					{ desc = "Reset the current line" }
				)

				vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
				vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
				vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
				vim.keymap.set("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

				vim.keymap.set("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, { desc = "Blame line" })

				vim.keymap.set("n", "<leader>gd", gitsigns.diffthis, { desc = "View diff for current file against the index" })

				vim.keymap.set(
					"n",
					"<leader>gD",
					function() gitsigns.diffthis("~") end,
					{ desc = "View diff for current file" }
				)

				vim.keymap.set(
					"n",
					"<leader>gQ",
					function() gitsigns.setqflist("all") end,
					{ desc = "Populate quickfix list with all hunks" }
				)
				vim.keymap.set("n", "<leader>gq", gitsigns.setqflist, { desc = "Populate quickfix list with hunks" })

				-- Toggles
				vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
				vim.keymap.set("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted" })
				vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

				-- Text object
				vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "inner hunk" })
			end,
		},
	},
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
		keys = {
			{ "<leader>gv", "<Cmd>DiffviewOpen<CR>", desc = "Open diff view" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
		},
		opts = function()
			local actions = require("diffview.actions")

			require("diffview.ui.panel").Panel.default_config_float.border = "rounded"

			return {
				default_args = { DiffviewFileHistory = { "%" } },
				icons = {
					folder_closed = "",
					folder_open = "󰝰",
				},
				signs = {
					fold_closed = "",
					fold_open = "",
					done = " ",
				},
				hooks = {
					diff_buf_read = function(_, _)
						vim.cmd("hi Cursor blend=100")
						vim.opt_local.relativenumber = false
					end,
					view_opened = function(_) vim.opt_local.sidescrolloff = 0 end,
				},
				keymaps = {
					disable_defaults = true,
					view = {
						{ "n", "<Tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{ "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
						{ "n", "[F", actions.select_first_entry, { desc = "Open the diff for the first file" } },
						{ "n", "]F", actions.select_last_entry, { desc = "Open the diff for the last file" } },
						{ "n", "[x", actions.prev_conflict, { desc = "Merge-tool: jump to the previous conflict" } },
						{ "n", "]x", actions.next_conflict, { desc = "Merge-tool: jump to the next conflict" } },
						{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
						{
							"n",
							"<leader>ct",
							actions.conflict_choose("theirs"),
							{ desc = "Choose the THEIRS version of a conflict" },
						},
						{ "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose the BASE version of a conflict" } },
						{ "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
						{ "n", "<leader>cn", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
						{
							"n",
							"<leader>cO",
							actions.conflict_choose_all("ours"),
							{ desc = "Choose the OURS version of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cT",
							actions.conflict_choose_all("theirs"),
							{ desc = "Choose the THEIRS version of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cB",
							actions.conflict_choose_all("base"),
							{ desc = "Choose the BASE version of a conflict for the whole file" },
						},
						unpack(actions.compat.fold_cmds),
					},
					diff2 = {
						{ "n", "?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
					},
					diff3 = {
						{ "n", "?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
					},
					file_panel = {
						{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
						{ "n", "S", actions.stage_all, { desc = "Stage all entries" } },
						{ "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
						{ "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
						{ "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
						{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
						{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
						{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
						{ "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
						{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
						{ "n", "[F", actions.select_first_entry, { desc = "Open the diff for the first file" } },
						{ "n", "]F", actions.select_last_entry, { desc = "Open the diff for the last file" } },
						{ "n", "i", actions.listing_style, { desc = 'Toggle between "list" and "tree" views' } },
						{ "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
						{ "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
						{ "n", "?", actions.help("file_panel"), { desc = "Open the help panel" } },
						{
							"n",
							"<leader>cO",
							actions.conflict_choose_all("ours"),
							{ desc = "Choose the OURS version of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cT",
							actions.conflict_choose_all("theirs"),
							{ desc = "Choose the THEIRS version of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cB",
							actions.conflict_choose_all("base"),
							{ desc = "Choose the BASE version of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cA",
							actions.conflict_choose_all("all"),
							{ desc = "Choose all the versions of a conflict for the whole file" },
						},
						{
							"n",
							"<leader>cD",
							actions.conflict_choose_all("none"),
							{ desc = "Delete the conflict region for the whole file" },
						},
					},
					file_history_panel = {
						{ "n", "!", actions.options, { desc = "Open the option panel" } },
						{ "n", "<leader>d", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
						{ "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
						{ "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
						{ "n", "X", actions.restore_entry, { desc = "Restore file to the state from the selected entry" } },
						{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
						{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
						{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
						{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<CR>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "<C-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<C-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
						{ "n", "<Tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{ "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
						{ "n", "[F", actions.select_first_entry, { desc = "Open the diff for the first file" } },
						{ "n", "]F", actions.select_last_entry, { desc = "Open the diff for the last file" } },
						{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
					},
					option_panel = {
						{ "n", "<Tab>", actions.select_entry, { desc = "Change the current option" } },
						{ "n", "q", actions.close, { desc = "Close the panel" } },
						{ "n", "?", actions.help("option_panel"), { desc = "Open the help panel" } },
					},
					help_panel = {
						{ "n", "q", actions.close, { desc = "Close help menu" } },
					},
				},
				hooks = {
					view_opened = function()
						vim.opt_local.laststatus = 3
					end,
				},
			}
		end,
	},
}
