return {
	"rmagatti/auto-session",
	lazy = false,
	keys = {
		{ "<leader>wr", "<Cmd>AutoSession restore<CR>", desc = "Restore session for cwd" },
		{ "<leader>ws", "<Cmd>AutoSession search<CR>", desc = "Search sessions" },
		{ "<leader>ww", "<cmd>AutoSession save<CR>", desc = "Save session" },
		{ "<leader>wt", "<Cmd>AutoSession toggle<CR>", desc = "Toggle session autosave" },
	},
	cmd = {
		"AutoSession",
	},
	opts = {
		auto_restore = false,
		git_use_branch_name = true,
		git_auto_restore_on_branch_change = true,
		args_allow_single_directory = true, -- Follow normal session save/load logic if launched with a single directory as the only argument
		args_allow_files_auto_save = true, -- Allow saving a session when launched with a file argument (or multiple files/dirs)


		bypass_save_filetypes = { "alpha" },
		close_filetypes_on_save = { "checkhealth", "neotree" },
		pre_restore_cmds = {
			function()
				if vim.bo.filetype == "neo-tree" then
					vim.cmd("Neotree close")
				end
			end,
		},
		post_restore_cmds = {
			"setlocal cursorline",
		},
		session_lens = {
			load_on_setup = false,
			preview = true,
		},
	},
}
