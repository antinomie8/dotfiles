vim.filetype.add({
	extension = {
		tex = "tex",
		tsqx = "tsqx",
		eml = "mail",
		asy = "asymptote",
	},
	filename = {
		["clang-format"] = "yaml",
		["dircolors"] = "dircolors",
	},
	pattern = {
		["${ZDOTDIR}/functions/.+"] = "zsh",
		["${HOME}/.config/neomutt/.+"] = "neomuttrc",
		["${HOME}/.config/kitty/.*.conf"] = "kitty",
		["${HOME}/.config/kitty/.*.conf.bak"] = "kitty",
	},
})
