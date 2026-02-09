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
				{ plugin = "yazi.nvim", icon = "󰇥 ", color = "yellow" },
				{ pattern = "error", icon = "󰅚 ", color = "red" },
				{ pattern = "warning", icon = "󰀪 ", color = "orange" },
				{ pattern = "documentation", icon = " ", color = "white" },
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
				{ plugin = "snacks.nvim", icon = " ", color = "blue" },
			},
		},
		spec = {
			{ "", icon = { icon = " ", color = "purple" } },
			{ "<leader>b", group = "Buffers", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>w", group = "Windows", icon = { icon = " ", color = "blue" } },
			{ "<leader>\t", group = "Tabs", icon = { icon = "󰓩 ", color = "purple" } },
			{ "<leader>q", group = "Quickfix", icon = { icon = " ", color = "grey" } },
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
			{ "<leader>R", icon = { icon = " ", hl = "DevIconJustfile" } },


			-- picker
			{ "<leader><space>", desc = "Smart Find Files", icon = { icon = "󰈞 ", color = "white" } },
			{ "<leader>,", desc = "Buffers", icon = { icon = "󰈔 ", color = "green" } },
			{ "<leader>/", desc = "Grep", icon = { icon = " ", color = "blue" } },
			{ "<leader>:", desc = "Command History", icon = { icon = " ", color = "blue" } },
			-- find
			{ "<leader>fb", desc = "Buffers", icon = { icon = "󰈔 ", color = "green" } },
			{ "<leader>ff", desc = "Find Files", icon = { icon = "󰈞 ", color = "white" } },
			{ "<leader>fg", desc = "Find Git Files", icon = { icon = " ", color = "red" } },
			{ "<leader>fp", desc = "Projects", icon = { icon = " ", color = "white" } },
			{ "<leader>fr", desc = "Find Recent Files", icon = { icon = " ", color = "blue" } },
			-- git
			{ "<leader>gb", desc = "Git Branches", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gl", desc = "Git Log", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gL", desc = "Git Log Line", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gs", desc = "Git Status", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gS", desc = "Git Stash", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gd", desc = "Git Diff (Hunks)", icon = { icon = "󰊢 ", color = "red" } },
			{ "<leader>gf", desc = "Git Log File", icon = { icon = "󰊢 ", color = "red" } },
			-- gh
			{ "<leader>gi", desc = "GitHub Issues (open)", icon = { icon = " ", color = "white" } },
			{ "<leader>gI", desc = "GitHub Issues (all)", icon = { icon = " ", color = "white" } },
			{ "<leader>gp", desc = "GitHub Pull Requests (open)", icon = { icon = " ", color = "white" } },
			{ "<leader>gP", desc = "GitHub Pull Requests (all)", icon = { icon = " ", color = "white" } },
			-- Grep
			{ "<leader>sb", desc = "Buffer Lines", icon = { icon = " ", color = "cyan" } },
			{ "<leader>sB", desc = "Grep Open Buffers", icon = { icon = "󱎸 ", color = "azure" } },
			{ "<leader>sg", desc = "Grep", icon = { icon = " ", color = "blue" } },
			{ "<leader>sw", desc = "Grep visual selection or word", mode = { "n", "x" }, icon = { icon = "󱈅 ", hl = "orange" } },
			-- search
			{ '<leader>s"', desc = "Registers", icon = { icon = "󰠷 ", color = "cyan" } },
			-- { "<leader>sr", desc = "Registers", icon = { icon = "󰠷 ", color = "cyan" } },
			{ "<leader>s/", desc = "Search History", icon = { icon = "󱎸 ", color = "white" } },
			{ "<leader>sa", desc = "Autocmds", icon = { icon = " ", color = "azure" } },
			{ "<leader>sc", desc = "Command History", icon = { icon = " ", color = "blue" } },
			{ "<leader>sC", desc = "Commands", icon = { icon = " ", color = "grey" } },
			{ "<leader>sd", desc = "Diagnostics", icon = { icon = " ", color = "red" } },
			{ "<leader>sD", desc = "Buffer Diagnostics", icon = { icon = "󰓙 ", color = "yellow" } },
			{ "<leader>sh", desc = "Help Pages", icon = { icon = "󰋗 ", color = "azure" } },
			{ "<leader>sH", desc = "Highlights", icon = { icon = " ", color = "orange" } },
			{ "<leader>si", desc = "Icons", icon = { icon = " ", color = "yellow" } },
			{ "<leader>sj", desc = "Jumps", icon = { icon = " ", color = "orange" } },
			{ "<leader>sk", desc = "Keymaps", icon = { icon = "󰌌 ", color = "blue" } },
			{ "<leader>sl", desc = "Location List", icon = { icon = " ", color = "purple" } },
			{ "<leader>sm", desc = "Marks", icon = { icon = " ", color = "blue" } },
			{ "<leader>sM", desc = "Man Pages", icon = { icon = "󱚊 ", color = "yellow" } },
			{ "<leader>sp", desc = "Search for Plugin Spec", icon = { icon = " ", color = "purple" } },
			{ "<leader>sq", desc = "Quickfix List", icon = { icon = " ", color = "grey" } },
			{ "<leader>sR", desc = "Resume", icon = { icon = "󰜉 ", color = "azure" } },
			{ "<leader>su", desc = "Undo History", icon = { icon = "󰕍 ", color = "orange" } },
			{ "<leader>uC", desc = "Colorschemes", icon = { icon = "🎨 ", color = "blue" } },
			{ "<leader>sn", desc = "Notification History", icon = { icon = " ", color = "cyan" } },
			-- LSP
			{ "grd", desc = "Goto Definition", icon = { icon = " ", color = "azure" } },
			{ "grD", desc = "Goto Declaration", icon = { icon = " ", color = "azure" } },
			{ "gri", desc = "Goto Implementation", icon = { icon = " ", color = "cyan" } },
			{ "grt", desc = "Goto Type Definition", icon = { icon = " ", color = "yellow" } },
			{ "grr", desc = "References", icon = { icon = "󰕡 ", color = "yellow" } },
			{ "grc", desc = "Incoming Calls", icon = { icon = "󱆓 ", color = "orange" } },
			{ "gro", desc = "Outgoing Calls", icon = { icon = "󱆙 ", color = "orange" } },
			{ "<leader>ss", desc = "LSP Symbols", icon = { icon = " ", color = "orange" } },
			{ "<leader>sS", desc = "LSP Workspace Symbols", icon = { icon = " ", color = "orange" } },
			-- misc
			{ "<leader>Z", desc = "Zoxide", icon = { icon = " ", color = "purple" } },

			-- LSP preview
			{ "gpd", desc = "Preview definition", icon = { icon = " ", color = "azure" } },
			{ "gpc", desc = "Preview declaration", icon = { icon = " ", color = "azure" } },
			{ "gpi", desc = "Preview implementation", icon = { icon = " ", color = "cyan" } },
			{ "gpt", desc = "Preview type definition", icon = { icon = " ", color = "yellow" } },
			{ "gpr", desc = "Preview references", icon = { icon = "󰕡 ", color = "yellow" } },
			{ "gpx", desc = "Close all previews", icon = { icon = "󱎘 ", color = "red" } },
			{ "gpX", desc = "Close other previews", icon = { icon = " ", color = "red" } },
		},
	},
}
