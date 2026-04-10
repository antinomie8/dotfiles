-- remove and reset terminal padding
local function kitty_set_padding(padding)
	if
		not vim.env.SPACING and
		not vim.env.LAZYGIT and
		not vim.env.YAZI_ID and
		not vim.env.NVIM and
		not vim.env.TMUX and
		vim.env.KITTY_LISTEN_ON and
		vim.env.KITTY_WINDOW_ID and
		not vim.tbl_contains(vim.v.argv, "--headless")
	then
		vim.system({
			"kitty",
			"@",
			"--to",
			vim.env.KITTY_LISTEN_ON,
			"set-spacing",
			"--match", "id:" .. vim.env.KITTY_WINDOW_ID,
			"padding=" .. padding,
		})
	end
end
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function() kitty_set_padding(20) end,
})
kitty_set_padding(0)
