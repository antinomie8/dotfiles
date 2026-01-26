return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function() require("which-key").show({ global = false }) end,
			desc = "Buffer Local Keymaps",
		},
	},
	opts = {
		defaults = {
			delay = 500,
		},
		plugins = {
			marks = true,   -- shows a list of your marks on ' and `
			registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			spelling = {
				enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
				suggestions = 26, -- how many suggestions should be shown in the list?
			},
			presets = {
				operators = true, -- adds help for operators like d, y, ...
				motions = true,  -- adds help for motions
				text_objects = true, -- help for text objects triggered after entering an operator
				windows = true,  -- default bindings on <c-w>
				nav = true,      -- misc bindings to work with windows
				z = true,        -- bindings for folds, spelling and others prefixed with z
				g = true,        -- bindings for prefixed with g
			},
		},
		win = {
			border = "single",
			width = 0.995,
			wo = {
				winblend = vim.o.pumblend,
			},
		},
		replace = {
			desc = {
				{ "<Plug>%(matchup%-i%%%)", "Match inside" },
				{ "<Plug>%(matchup%-a%%%)", "Match around" },
				{ "<Plug>%(matchup%-z%%%)", "Next match" },
				{ "<Plug>%(vimtex%-([^-]*)%-?([^-]*)%)", "%1 %2" },
				{ "<Plug>%((%w+)%-(%w+)%-(%w+)%)", "%1 %2 %3" },
				{ "<Plug>%((%w+)%-(%w+)%)", "%1 %2" },
				{
					"<Cmd>lua require'nvim%-treesitter.textobjects.select'.select_textobject%('@(%a+)%.(%a+)','textobjects','.'%)<CR>",
					"%2 %1",
				},
			},
		},
		icons = {
			rules = { -- uppercase letters are not allowed in the pattern
				-- { plugin = "snacks.nvim", icon = " ", color = "blue" },
				{ plugin = "yazi.nvim", icon = "󰇥 ", color = "yellow" },
				{ pattern = "error", icon = "󰅚 ", color = "red" },
				{ pattern = "warning", icon = "󰀪 ", color = "orange" },
				{ pattern = "documentation", icon = " ", color = "white" },
				{ pattern = "definition", icon = " ", color = "azure" },
				{ pattern = "declaration", icon = " ", color = "azure" },
				{ pattern = "references", icon = "󰕡 ", color = "yellow" },
				{ pattern = "code action", icon = " ", color = "yellow" },
				{ pattern = "next [(<{]", icon = "󰒭", color = "yellow" },
				{ pattern = "previous [(<{]", icon = "󰒮", color = "yellow" },
				{ pattern = "^inner", icon = "󰼢 ", color = "white" },
				{ pattern = "^outer", icon = "󰃎 ", color = "white" },
				{ pattern = "block$", icon = "󱡠 ", color = "white" },
				{ pattern = "paragraph", icon = "󰚟 ", color = "white" },
				{ pattern = "increment", icon = " ", color = "white" },
				{ pattern = "decrement", icon = " ", color = "white" },
				{ pattern = "github", icon = " ", color = "white" },
				{ pattern = "git", icon = "󰊢 ", color = "red" },
				{ pattern = "^choose ", icon = " ", color = "red" },
				{ pattern = "yazi", icon = "󰇥 ", color = "yellow" },
				{ pattern = "context", icon = "󱎸 ", color = "green" },
				{ pattern = "paste", icon = "󰅇 ", color = "yellow" },
				{ pattern = "session", icon = " ", color = "azure" },
				{ pattern = "directory", icon = " ", color = "blue" },
				{ pattern = "file", icon = "", color = "cyan" },
				{ pattern = "list", icon = " ", color = "white" },
				{ pattern = "fold", icon = " ", color = "white" },
				{ pattern = "misspell", icon = " ", color = "red" },
				{ pattern = "unmatched group", icon = " ", color = "red" },
				{ pattern = "match", icon = "󰘦 ", color = "white" },
				{ pattern = "code outline", icon = "󱏒 ", color = "blue" },
				{ pattern = "split.+join", icon = "󰤻 ", color = "azure" },
				{ pattern = "symbols in winbar", icon = " ", color = "orange" },
				{ pattern = "highlight", icon = " ", color = "orange" },
				{ pattern = "substitute", icon = " ", color = "orange" },
				{ pattern = "replace", icon = " ", color = "orange" },
			},
		},
		spec = {
			{ "", icon = { icon = " ", color = "purple" } },
			{ "<leader>b", group = "Buffers", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>w", group = "Windows", icon = { icon = " ", color = "blue" } },
			{ "<leader>\t", group = "Tabs", icon = { icon = "󰓩 ", color = "purple" } },
			{ "<leader>q", group = "Quickfix", icon = { icon = " ", color = "green" } },
			{ "<leader>d", group = "Debugger", icon = { icon = " ", color = "red" } },
			{ "<leader>g", group = "Git", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>f", group = "Files", icon = { icon = "", color = "blue" } },
			{ "<leader>o", group = "Toggle options", icon = { icon = " ", color = "yellow" } },
			{ "<leader>t", group = "Tabs", icon = { icon = "󰓩 ", color = "purple" } },
			{ "gp", group = "LSP preview", icon = { icon = " ", color = "blue" } },
			{
				"<localleader>",
				icon = function()
					local icon, hl = require("nvim-web-devicons").get_icon(vim.fn.expand("%"), vim.fn.expand("%:e"))
					return { icon = icon, hl = hl }
				end,
			},
			{
				"<localleader>l",
				group = "LazyGit",
				icon = { icon = "󰊢 ", color = "red" },
				cond = vim.bo.filetype == "lazy",
			},
		},
	},
}
