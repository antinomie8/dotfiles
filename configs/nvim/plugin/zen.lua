-- Zen mode
vim.api.nvim_create_user_command("Zen", function()
	if not vim.g.zen_mode then
		vim.opt.number, vim.opt.relativenumber = false, false
		vim.opt.laststatus, vim.opt.showtabline = 0, 0
		vim.opt.signcolumn = "no"
		vim.opt.winbar = nil
	else
		vim.opt.number, vim.opt.relativenumber = true, true
		vim.opt.laststatus, vim.opt.showtabline = 3, 2
		vim.opt.signcolumn = "yes"
		vim.opt.winbar = "winbar=%{%v:lua.dropbar()%}"
	end
	vim.g.zen_mode = not vim.g.zen_mode
end, {})
