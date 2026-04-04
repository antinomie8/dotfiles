return {
	---opens a vertical split with cppman's output
	---@param match (string)
	open = function(match)
		vim.system({ "cppman", match }, function(obj)
			-- open a new vertical split
			vim.cmd.enew()
			vim.cmd.file("man://" .. match)
			local buf = vim.api.nvim_get_current_buf()

			-- set buffer options
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].swapfile = false
			vim.bo[buf].filetype = "man"

			-- set lines
			vim.bo[buf].modifiable = true
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(obj.stdout, "\n"))
			vim.bo[buf].modifiable = false
		end)
	end,
}
