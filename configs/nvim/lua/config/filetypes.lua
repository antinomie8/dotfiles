vim.filetype.add({
	extension = {
		tex = "tex",
		tsqx = "tsqx",
		eml = "mail",
	},
	filename = {
		["clang-format"] = "yaml",
		["dircolors"] = "dircolors",
	},
	pattern = {
		["${HOME}/.config/neomutt/.+"] = "neomuttrc",
		["${HOME}/.config/kitty/.*.conf"] = "kitty",
		["${HOME}/.config/kitty/.*.conf.bak"] = "kitty",
	},
})
