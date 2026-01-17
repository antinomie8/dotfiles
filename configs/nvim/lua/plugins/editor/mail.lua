return {
	"anonymousgrasshopper/notmuch.nvim",
	branch = "feat/buffer-local-variables",
	cmd = { "Notmuch", "NmSearch", "Inbox", "ComposeMail" },
	init = function()
		vim.api.nvim_create_user_command("Inbox", function(arg)
			local nm = require("notmuch")
			if #arg.fargs ~= 0 then
				nm.search_terms("tag:inbox to:" .. arg.args)
			else
				nm.search_terms("tag:inbox")
			end
		end, {
			desc = "Open inbox",
			nargs = "?",
			complete = function(ArgLead, CmdLine, CursorPos)
				local result = vim.system({ "notmuch", "address", "*" }):wait()
				if result.code ~= 0 then return {} end

				-- split stdout to a list of lines
				local matches = {}
				for line in result.stdout:gmatch("[^\r\n]+") do
					table.insert(matches, line)
				end
				return matches
			end,
			force = true,
		})
	end,
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
