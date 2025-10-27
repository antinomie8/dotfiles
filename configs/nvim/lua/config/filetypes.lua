vim.filetype.add({
	extension = {
		muttrc = "neomuttrc",
		tex = "tex",
		tsqx = "tsqx",
	},
	filename = {
		["clang-format"] = "yaml",
		["dircolors"] = "dircolors",
	},
	pattern = {
		["${HOME}/.config/mutt/.+"] = "neomuttrc",
		["${HOME}/.config/kitty/.*.conf"] = "kitty",
		["${HOME}/.config/kitty/.*.conf.bak"] = "kitty",
	},
})
