-- Zen mode
vim.api.nvim_create_user_command("Zen", function()
	if vim.api.nvim_get_option_value("laststatus", {}) ~= 0 then
		vim.opt.laststatus = 0
		vim.opt.showtabline = 0
		vim.g.zen_mode = true
		if vim.env.TMUX then
			vim.system({ "tmux", "set", "-g", "status", "off" })
		end
	else
		vim.opt.laststatus = 3
		vim.opt.showtabline = 2
		vim.g.zen_mode = false
		if vim.env.TMUX then
			vim.system({ "tmux", "set", "-g", "status", "on" })
		end
	end
end, {})
