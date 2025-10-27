vim.keymap.set("i", "<CR>",
	function()
		if vim.api.nvim_win_get_cursor(0)[1] == 1 then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, true, true), "", false)
		else
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc><CR>", true, true, true), "", false)
		end
	end, { desc = "Execute", buffer = true })
