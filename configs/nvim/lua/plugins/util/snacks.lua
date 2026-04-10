return {
	"antionmie8/snacks.nvim",
	branch = "master",
	lazy = false,
	priority = 1000,
	keys = {
		{
			"<leader>lg",
			function()
				require("snacks.terminal").open("lazygit")
			end,
			desc = "Open Lazygit",
		},
		{
			"<C-_>",
			function()
				require("snacks.terminal").toggle(nil, {
					win = {
						position = "float",
						border = "rounded",
						backdrop = false,
						wo = { winblend = 15 },
					},
				})
			end,
			mode = { "n", "t" },
			desc = "Toggle terminal",
		},

		{ "<localleader>.", function() require("snacks.scratch")() end, desc = "Toggle Scratch Buffer" },
		{ "<localleader>%", function() require("snacks.scratch").select() end, desc = "Select Scratch Buffer" },

		{ "]r", function() require("snacks.words").jump(vim.v.count1) end },
		{ "[r", function() require("snacks.words").jump(-vim.v.count1) end },
	},
	init = function()
		vim.api.nvim_create_user_command("Nerdy", function()
			require("snacks.picker").icons()
		end, {})

		vim.api.nvim_create_autocmd("User", {
			pattern = "SnacksDashboardOpened",
			callback = function()
				vim.cmd("hi Cursor blend=100")
			end,
		})

		local function toggle(option, keys, name)
			local map = require("snacks.toggle").option(option)
			map.opts.name = name
			map:map(keys)
		end
		toggle("spell", "<leader>os", "spell checking")
		toggle("wrap", "<leader>ow", "line wrapping")
		toggle("relativenumber", "<leader>or", "relative numbering")
		toggle("autochdir", "<leader>oa", "directory syncing with buffer")
		require("snacks.toggle").diagnostics():map("<leader>od")
		require("snacks.toggle").inlay_hints():map("<leader>oi")
	end,
	opts = {
		bigfile = {},
		bufdelete = {},
		rename = {},
		words = {},
		image = {
			-- icons = {
			-- 	math = "",
			-- 	chart = "",
			-- 	image = "",
			-- },
			doc = {
				inline = false,
				max_width = 40,
				max_height = 20,
			},
			math = {
				enabled = false,
			},
		},
		input = {},
		scratch = {
			name = "Notepad",
			icon = "󰠮",
		},
		styles = {
			scratch = {
				footer_keys = false,
			},
		},
		terminal = {
			auto_close = false,
			on = {
				TermClose = function(terminal)
					terminal:close()
					vim.cmd.checktime()

					vim.api.nvim_exec_autocmds("WinEnter", { buffer = 0 })
					vim.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
				end,
			},
		},
		toggle = {
			notify = false,
		},
	},
}
