return {
	"yousefakbar/notmuch.nvim",
	-- branch = "refactor/lua-rewrite",
	branch = "refactor/thread-json-parsing",
	cmd = { "Notmuch", "NmSearch", "Inbox", "ComposeMail" },
	opts = {
		maildir_sync_cmd = "mbsync -a",
		sync = {
			sync_mode = "background", -- "buffer" or "background"
		},
		keymaps = {
			sendmail = "<C-g><C-g>",
		},
	},
}
