return {
	"yousefakbar/notmuch.nvim",
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
