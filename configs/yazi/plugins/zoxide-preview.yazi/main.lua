return {
	entry = function()
		local zoxide = require("zoxide")
		local options = zoxide.options()
		zoxide.options = function()
			return options
				.. [[ --preview='eza -G --icons --color=always --no-quotes --group-directories-first -- {2..}']]
		end
		zoxide:entry()
	end,
}
