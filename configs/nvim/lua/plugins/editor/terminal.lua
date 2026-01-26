return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = {
		"ToggleTerm",
		"Btop",
	},
	keys = {
		{ "<c-_>", "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
		{
			"<leader>lg",
			function()
				require("toggleterm.terminal").Terminal:new({
					cmd = "lazygit",
					dir = "git_dir",
					hidden = true,
					direction = "float",
					display_name = "LazyGit",
					close_on_exit = true,
					float_opts = {
						border = "rounded",
					},
				}):toggle()
			end,
			desc = "Open LazyGit",
		},
	},
	opts = function()
		local Terminal = require("toggleterm.terminal").Terminal

		local btop = Terminal:new({
			cmd = "btop",
			hidden = true,
			direction = "float",
			display_name = "Top",
			close_on_exit = true,
			float_opts = {
				border = "solid",
			},
			highlights = {
				NormalFloat = { guibg = "#16161d" },
				FloatBorder = { guibg = "#16161d" },
			},
		})

		vim.api.nvim_create_user_command("Btop", function() btop:toggle() end, {})

		return {
			shade_terminals = false,
			start_in_insert = true,
			autochdir = true,
			direction = "float",
			float_opts = {
				border = "rounded",
				winblend = 10,
				zindex = 5,
			},
			highlights = {
				Normal = { guibg = "#16161d" },
				FloatBorder = { guibg = "none", guifg = "#54546d" },
			},
		}
	end,
}
