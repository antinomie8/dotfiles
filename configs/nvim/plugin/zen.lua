-- Zen mode
vim.api.nvim_create_user_command("Zen", function()
	if not vim.g.zen_mode then
		vim.g.zen_mode = true
		vim.opt.laststatus = 0
		vim.opt.showtabline = 0
		vim.opt.winbar = nil
		if vim.env.TMUX then
			vim.system({ "tmux", "set", "-g", "status", "off" })
		end
	else
		vim.g.zen_mode = false
		vim.opt.laststatus = 3
		vim.opt.showtabline = 2
		vim.opt.winbar = "winbar=%{%v:lua.dropbar()%}"
		if vim.env.TMUX then
			vim.system({ "tmux", "set", "-g", "status", "on" })
		end
	end
end, {})
