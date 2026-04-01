vim.loader.enable()

-- remove terminal padding
if not vim.env.NVIM and not vim.env.TMUX and not vim.env.YAZI_ID and vim.env.KITTY_LISTEN_ON then
	vim.system({ "kitty", "@", "--to", vim.env.KITTY_LISTEN_ON, "set-spacing", "padding=0" })
end

require("config.autocmds")
require("config.filetypes")
require("config.keymaps")
require("config.options")

-- download lazy.nvim if it isn't here yet
local lazypath = vim.fn.stdpath("data") .. "/pack/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- defer notifications happening during startup
_G.pending_notifications = {
	old_notify = vim.notify,
}
local newNotify = function(...) table.insert(_G.pending_notifications, vim.F.pack_len(...)) end
vim.notify = newNotify

vim.defer_fn(function()
	if vim.notify == newNotify then
		vim.notify = _G.pending_notifications.old_notify
	end
	for _, args in ipairs(_G.pending_notifications) do
		vim.notify(vim.F.unpack_len(args))
	end
	_G.pending_notifications = nil
end, 150)

-- setup plugins
require("lazy").setup({
	root = vim.fn.stdpath("data") .. "/pack",
	lockfile = vim.fn.stdpath("config") .. "/lockfile.json",
	readme = { root = vim.fn.stdpath("state") .. "docs/readme" },
	local_spec = false, -- wether to source .lazy.lua
	spec = {
		{ import = "plugins.coding" },
		{ import = "plugins.core" },
		{ import = "plugins.editor" },
		{ import = "plugins.lang" },
		{ import = "plugins.ui" },
		{ import = "plugins.util" },
	},
	install = {
		missing = false,
		colorscheme = { "kanagawa-wave" },
	},
	diff = {
		cmd = "diffview.nvim",
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tutor",
			},
		},
	},
})
