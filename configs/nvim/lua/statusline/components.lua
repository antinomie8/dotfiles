local components = {}

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
utils["truncate"] = function(str, thresh, is_winbar)
	local winwidth
	if vim.o.laststatus == 3 and not is_winbar then
		winwidth = vim.o.columns
	else
		winwidth = vim.api.nvim_win_get_width(0)
	end
	local len_max = math.floor(winwidth * thresh)
	if #str <= len_max then
		return str
	else
		return str:sub(1, len_max - 1) .. "…"
	end
end

components.Space = { provider = " " }

components.LeftSeparator = {
	provider = "",
	hl = function(self) return { fg = self.separator_color } end,
}
components.RightSeparator = {
	provider = "",
	hl = function(self) return { fg = self.separator_color } end,
}

components.ViMode = {
	static = {
		mode_names = {
			n = "NORMAL",
			no = "NORMAL-",
			nov = "NORMAL-",
			noV = "NORMAL-",
			["no\22"] = "NORMAL-",
			niI = "NORMAL-",
			niR = "NORMAL-",
			niV = "NORMAL-",
			nt = "NORMAL-",
			v = "VISUAL",
			vs = "VISUAL-",
			V = "V-LINE",
			Vs = "V-LINE-",
			["\22"] = "V-BLOCK",
			["\22s"] = "V-BLOCK-",
			s = "SELECT",
			S = "S-LINE",
			["\19"] = "S-BLOCK",
			i = "INSERT",
			ic = "INSERT-",
			ix = "INSERT-",
			R = "REPLACE",
			Rc = "REPLACE-",
			Rx = "REPLACE-",
			Rv = "REPLACE-",
			Rvc = "REPLACE-",
			Rvx = "REPLACE-",
			c = "COMMAND",
			cv = "COMMAND-",
			r = "PROMPT",
			rm = "MORE",
			["r?"] = "CONFIRM",
			["!"] = "SHELL",
			t = "TERMINAL",
		},
	},
	provider = function(self) return self.mode_names[self.mode] end,
}

components.Git = {
	condition = conditions.is_git_repo,

	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict or {}
		self.has_changes = self.status_dict.added ~= 0 or
		                   self.status_dict.removed ~= 0 or
		                   self.status_dict.changed ~= 0
	end,

	hl = { fg = "fg" },

	components.Space,
	{ -- git branch name
		provider = function(self) return " " .. self.status_dict.head end,
	},
	components.Space,
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and (" " .. count .. " ")
		end,
		hl = "GitSignsAdd",
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and (" " .. count .. " ")
		end,
		hl = "GitSignsChange",
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and (" " .. count .. " ")
		end,
		hl = "GitSignsDelete",
	},
}

local FileNameBlock = {
	init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
}

local FileName = {
	provider = function(self)
		local filename = vim.fn.fnamemodify(self.filename, ":~")
		if filename == "" then
			return "[No Name]"
		end
		local shorten_length = 5
		while not conditions.width_percent_below(#filename, 0.60) and shorten_length >= 2 do
			filename = vim.fn.pathshorten(filename, shorten_length)
			shorten_length = shorten_length - 1
		end
		return filename
	end,
	hl = { fg = "fg" },
}

local FileIcon = {
	init = function(self)
		local filename = self.filename
		local extension = vim.fn.fnamemodify(filename, ":e")
		self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
	end,
	provider = function(self) return self.icon and self.icon end,
	hl = function(self) return { fg = self.icon_color } end,
}

local FileFlags = {
	{
		condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
		provider = " ",
		hl = { fg = "fg" },
	},
	{
		condition = function()
			local filename = vim.fn.expand("%")
			if
				filename ~= ""
				and filename:match("^%a+://") == nil
				and vim.bo.buftype == ""
				and vim.fn.filereadable(filename) == 0
			then
				return true
			end
			return false
		end,
		provider = " ",
	},
	{
		condition = function() return vim.bo.modified end,
		provider = " ●",
		hl = { fg = "green" },
	},
}

components.FileNameBlock = utils.insert(
	FileNameBlock,
	FileName,
	components.Space,
	FileIcon,
	components.Space,
	FileFlags,
	{ provider = "%<" } -- this means that the statusline is cut here when there's not enough space
)

components.Macro = {
	condition = function() return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0 end,
	provider = function() return " " .. vim.fn.reg_recording() .. "  " end,
	hl = { fg = "orange"},
	update = {
		"RecordingEnter",
		"RecordingLeave",
	},
}

local function OverseerTasksForStatus(status)
	return {
		condition = function(self) return self.tasks[status] end,
		provider = function(self) return string.format("%s%d ", self.symbols[status], #self.tasks[status]) end,
		hl = function(self)
			return {
				fg = utils.get_highlight(string.format("Overseer%s", status)).fg,
			}
		end,
	}
end
components.Overseer = {
	condition = function() return package.loaded.overseer end,
	init = function(self)
		local tasks = require("overseer.task_list").list_tasks({ unique = true })
		local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
		self.tasks = tasks_by_status
	end,
	static = {
		symbols = {
			["CANCELED"] = " ",
			["FAILURE"] = " ",
			["SUCCESS"] = "󰄴 ",
			["RUNNING"] = "󰑮 ",
		},
	},

	OverseerTasksForStatus("CANCELED"),
	OverseerTasksForStatus("RUNNING"),
	OverseerTasksForStatus("SUCCESS"),
	OverseerTasksForStatus("FAILURE"),
}

components.Debugger = {
	condition = function()
		if package.loaded.dap then
			local session = require("dap").session()
			return session ~= nil
		end
		return false
	end,
	provider = function() return " " .. require("dap").status() end,
	hl = "Debug",
	-- see Click-it! section for clickable actions
}

components.Diagnostics = {
	condition = function()
		return conditions.has_diagnostics() and vim.diagnostic.is_enabled()
	end,

	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

		self.error_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.ERROR]
		self.warn_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.WARN]
		self.info_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.INFO]
		self.hint_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.HINT]
	end,

	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self) return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ") end,
		hl = "DiagnosticSignError",
	},
	{
		provider = function(self) return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ") end,
		hl = "DiagnosticSignWarn",
	},
	{
		provider = function(self) return self.info > 0 and (self.info_icon .. " " .. self.info .. " ") end,
		hl = "DiagnosticSignInfo",
	},
	{
		provider = function(self) return self.hints > 0 and (self.hint_icon .. " " .. self.hints .. " ") end,
		hl = "DiagnosticSignHint",
	},
}

components.Ruler = {
	provider = "%P %5(%l:%c%)",
	hl = { fg = "fg", bg = "grey" },
}

components.Time = {
	static = {
		clocks = { "󱑋 ", "󱑌 ", "󱑍 ", "󱑎 ", "󱑏 ", "󱑐 ", "󱑑 ", "󱑒 ", "󱑓 ", "󱑔 ", "󱑕 ", "󱑖 " }
	},
	provider = function(self)
		local date =  os.date("%R")
		local hour = tonumber(tostring(date):sub(1, 2))
		local icon = self.clocks[hour % 12 + 1]
		return icon .. date
	end,
}

local function is_loclist() return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0 end

local extension_filetypes = {
	"aerial",
	"checkhealth",
	"CompetiTest",
	"dap-repl",
	"dapui_scopes",
	"dapui_stacks",
	"dapui_watches",
	"dapui_console",
	"dapui_breakpoints",
	"DiffviewFiles",
	"fugitive",
	"git",
	"lazy",
	"man",
	"mail",
	"neo-tree",
	"notmuch-threads",
	"qf",
	"toggleterm",
	"TelescopePrompt",
	"yazi",
	"undotree",
}

components.ExtensionA = {
	condition = function() return vim.tbl_contains(extension_filetypes, vim.bo.filetype) end,
	init = function(self)
		self.ft = vim.bo.filetype
		self.filetype_data = {
			["aerial"] = "Aerial",
			["checkhealth"] = "Health",
			["CompetiTest"] = function() return vim.b.competitest_title or "CompetiTest" end,
			["dap-repl"] = "repl",
			["dapui_scopes"] = "Scopes",
			["dapui_stacks"] = "Call Stack",
			["dapui_watches"] = "Watches",
			["dapui_console"] = "Console",
			["dapui_breakpoints"] = "Breakpoints",
			["DiffviewFiles"] = function() return " " .. (vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.head or " ") end,
			["fugitive"] = function() return " " .. (vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.head or " ") end,
			["git"] = function() return " " .. (vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.head or " ") end,
			["lazy"] = "Lazy",
			["mail"] = function()
				local from = vim.b.From
				if from then
					return from:match("^([^<]*) <")
				else
					return "Mail"
				end
			end,
			["man"] = "MAN",
			["neo-tree"] = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end,
			["notmuch-threads"] = "Mail",
			["qf"] = function() return is_loclist() and "Location List" or "Quickfix List" end,
			["TelescopePrompt"] = "Telescope",
			["toggleterm"] = function() return "Terminal #" .. vim.b.toggle_number end,
			["yazi"] = "Yazi",
			["undotree"] = "Undotree",
		}
	end,
	provider = function(self)
		if type(self.filetype_data[self.ft]) == "function" then
			return self.filetype_data[self.ft]()
		else
			return self.filetype_data[self.ft]
		end
	end,
}

components.ExtensionB = {
	init = function(self)
		local git_root = require("utils.git").git_root
		self.ft = vim.bo.filetype
		self.filetype_data = {
			["checkhealth"] = "󰓙 ",
			["lazy"] = function() return "loaded: " .. require("lazy").stats().loaded .. "/" .. require("lazy").stats().count end,
			["man"] = function() return vim.fn.expand("%"):sub(7) end,
			["diffview"] = git_root,
			["fugitive"] = git_root,
			["git"] = git_root,
			["qf"] = function()
				if is_loclist() then
					return utils.truncate(vim.fn.getloclist(0, { title = 0 }).title, 0.60)
				else
					return utils.truncate(vim.fn.getqflist({ title = 0 }).title, 0.60)
				end
			end,
		}
	end,
	condition = function(self)
		return vim.tbl_contains({
			"checkhealth",
			"lazy",
			"man",
			"diffview",
			"fugitive",
			"git",
			"qf",
		}, vim.bo.filetype)
	end,
	components.Space,
	{
		provider = function(self)
			if type(self.filetype_data[self.ft]) == "function" then
				return self.filetype_data[self.ft]()
			else
				return self.filetype_data[self.ft]
			end
		end,
	},
	components.Space,
}

components.ExtensionC = {
	condition = function() return vim.tbl_contains(extension_filetypes, vim.bo.filetype) end,
	init = function(self)
		self.ft = vim.bo.filetype
		self.filetype_data = {
			["lazy"] = function()
				if pcall(require("lazy.status").has_updates) then
					return require("lazy.status").updates()
				end
			end,
			["mail"] = function()
				local subject = vim.b.Subject
				if subject then
					return utils.truncate(subject, 0.60)
				end
			end,
			["man"] = "󱚊",
		}
	end,
	{
		provider = function(self)
			if type(self.filetype_data[self.ft]) == "function" then
				return self.filetype_data[self.ft]()
			else
				return self.filetype_data[self.ft]
			end
		end,
	},
	components.Space,
}

components.ExtensionY = {
	condition = function(self) return self.filetype_data[vim.bo.filetype] end,
	init = function(self) self.ft = vim.bo.filetype end,
	static = {
		filetype_data = {
			["aerial"] = "󱏒",
			["CompetiTest"] = "",
			["dap-repl"] = "",
			["dapui_scopes"] = "",
			["dapui_stacks"] = "",
			["dapui_watches"] = "",
			["dapui_console"] = "",
			["dapui_breakpoints"] = "",
			["DiffviewFiles"] = "󰊢",
			["lazy"] = "󰒲",
			["mail"] = function()
				local date = vim.b.Date
				if date then
					return date:match("^(.*%d%d%d%d) %d%d:%d%d:%d%d")
				else
					return components.Ruler.provider
				end
			end,
			["neo-tree"] = "󰙅",
			["notmuch-threads"] = function() return "󰇯 " .. vim.api.nvim_buf_line_count(0) - 1 end,
			["TelescopePrompt"] = "󰭎",
			["toggleterm"] = " ",
			["undotree"] = "󱁊",
			["yazi"] = "󰇥",
		},
	},
	provider = function(self)
		if type(self.filetype_data[self.ft]) == "function" then
			return self.filetype_data[self.ft]()
		else
			return self.filetype_data[self.ft]
		end
	end,
}

return components
