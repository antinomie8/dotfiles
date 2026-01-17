return {
	"folke/noice.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<A-x>",
			"<Cmd>Noice dismiss<CR>",
			mode = { "n", "i", "c", "v" },
			desc = "Dismiss all notifications",
		},
	},
	dependencies = {
		-- MunifTanjim/nui.nvim
		{
			"anonymousgrasshopper/nvim-notify",
			opts = function()
				if package.loaded["telescope"] then
					require("telescope").load_extension("notify")
				end
				return {
					timeout = 3000,
					on_open = function(win) vim.api.nvim_win_set_config(win, { zindex = 100 }) end,
				}
			end,
		},
	},
	opts = {
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			lsp_doc_border = true, -- add a border to hover docs and signature help
		},
		cmdline = {
			format = {
				cmdline = {
					pattern = "^:",
					icon = " ",
					title = "",
					lang = "vim",
				},
				search_down = {
					view = "cmdline",
				},
				search_up = {
					view = "cmdline",
				},
				filter = { title = "" },
				lua = { title = "" },
				help = { title = "" },
				input = { title = "" },
			},
		},
		messages = {
			view_search = false, -- view for search count messages. "virtualtext" or 'false' to disable
		},
		lsp = {
			progress = {
				enabled = false,
			},
			signature = {
				enabled = false,
			},
		},
		views = {
			cmdline_popup = {
				border = {
					style = "single",
				},
				filter_options = {},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
		},
		routes = {
			{
				filter = {
					event = "lsp",
					kind = "progress",
					cond = function(message)
						local client = vim.tbl_get(message.opts, "progress", "client")
						return client == "lua_ls"
					end,
				},
				opts = { skip = true },
			},
			{ -- get rid of empty messages like when running :checkhealth
				filter = {
					event = "notify",
					kind = "info",
					any = {
						{ find = "^$" },
					},
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "notify",
					kind = "warn",
					cond = function(message)
						return message.opts.title == "telescope.nvim" --[[ and message.content():match("Nothing currently selected") ]]
					end,
				},
				opts = { skip = true },
			},
		},
	},
}
