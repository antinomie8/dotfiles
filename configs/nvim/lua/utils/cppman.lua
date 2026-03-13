return {
	---@param match (string)
	open = function(match)
		-- get cppman output
		local handle = io.popen("cppman " .. match)
		if handle then
			local result = handle:read("*a")
			handle:close()

			-- open a new vertical split
			vim.cmd.enew()
			vim.cmd.file("man://" .. match)
			local buf = vim.api.nvim_get_current_buf()

			-- set buffer options
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].swapfile = false
			vim.bo[buf].filetype = "man"
			vim.bo[buf].modifiable = true

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))

			vim.bo[buf].modifiable = true
		end
	end,
}
