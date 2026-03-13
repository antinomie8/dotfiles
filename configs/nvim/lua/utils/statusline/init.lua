local components = require("utils.statusline.components")

local SectionA = {
	init = function(self) self.mode = vim.fn.mode(1) end,
	hl = function(self)
		return {
			fg = "bg",
			bg = self:mode_color(),
		}
	end,
	static = {
		separator_color = "grey",
	},
	components.Space,
	{
		fallthrough = false,
		components.ExtensionA,
		components.ViMode,
	},
	components.Space,
	components.LeftSeparator,
}

local SectionB = {
	hl = { bg = "grey", fg = "fg" },
	static = {
		separator_color = "bg",
	},
	{
		fallthrough = false,
		components.ExtensionB,
		components.Git,
	},
	components.LeftSeparator,
}

local SectionC = {
	hl = { bg = "bg", fg = "fg" },
	components.Space,
	{
		fallthrough = false,
		components.ExtensionC,
		components.FileNameBlock,
	},
}

local Align = { provider = "%=" }

local SectionX = {
	hl = { bg = "bg", fg = "fg" },
	components.Macro,
	components.Debugger,
	components.Overseer,
	components.Diagnostics,
}

local SectionY = {
	hl = { bg = "grey", fg = "fg" },
	static = {
		separator_color = "bg",
	},
	components.RightSeparator,
	components.Space,
	{
		fallthrough = false,
		components.ExtensionY,
		components.Ruler,
	},
	components.Space,
}

local SectionZ = {
	init = function(self) self.mode = vim.fn.mode(1) end,
	hl = function(self)
		return {
			fg = "bg",
			bg = self:mode_color(),
		}
	end,
	static = {
		separator_color = "grey",
	},
	components.RightSeparator,
	components.Space,
	components.Time,
	components.Space,
}

local Statusline = {
	SectionA,
	SectionB,
	SectionC,
	Align,
	SectionX,
	SectionY,
	SectionZ,
}

return {
	hl = "Statusline",
	static = {
		mode_colors = {
			n = "blue",
			i = "green",
			v = "violet",
			V = "violet",
			["\22"] = "blue",
			c = "yellow",
			s = "violet",
			S = "violet",
			["\19"] = "violet",
			R = "red",
			r = "red",
			["!"] = "red",
			t = "yellow",
		},
		mode_color = function(self)
			local mode = vim.fn.mode() or "n"
			return self.mode_colors[mode]
		end,
	},
	Statusline,
}
