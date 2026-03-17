return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	keys = {
		{ "<localleader>.", function() require("snacks.scratch")() end, desc = "Toggle Scratch Buffer" },
		{ "<localleader>%", function() require("snacks.scratch").select() end, desc = "Select Scratch Buffer" },
	},
	init = function()
		vim.api.nvim_create_user_command("Nerdy", function()
			require("snacks.picker").icons()
		end, {})

		vim.api.nvim_create_autocmd("UIEnter", {
			callback = function()
				vim.schedule(function()
					if vim.bo.filetype == "dashboard" then
						vim.cmd("hi Cursor blend=100")
					end
				end)
			end,
		})
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
		-- scroll = {}, -- cannot disable for specific motions
	},
}
