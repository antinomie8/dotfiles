-- type 's ' in the command line to substitute with very magic mode
vim.api.nvim_create_autocmd("CmdlineChanged", {
	callback = function()
		local cmd_type = vim.fn.getcmdtype()
		local cmd_text = vim.fn.getcmdline()

		if cmd_type == ":" then
			if cmd_text == "s " then
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes("<C-u>%s@\\v@<Left>", true, false, true),
					"n",
					false
				)
			elseif cmd_text == "'<,'>s " then
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes("<C-u>'<,'>s@\\v@<Left>", true, false, true),
					"n",
					false
				)
			else
				local match = cmd_text:match("(%d+,%s*%d+%s*s) ")
				if match then
					vim.api.nvim_feedkeys(
						vim.api.nvim_replace_termcodes("<C-u>" .. match .. "@\\v@<Left>", true, false, true),
						"n",
						false
					)
				end
			end
		end
	end,
})
