return {
	{
		"antinomie8/nvim-notify",
		event = "VeryLazy",
		opts = {
			timeout = 3000,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
				vim.wo[win].winfixbuf = true

				vim.keymap.set("n", "gf", function()
					local line = vim.api.nvim_get_current_line()
					local file, linenr = line:match("callback: ([/.].*):(%d*): ")
					if file and vim.startswith(file, "...") then
						file = file:gsub("%.%.%..*nvim/", vim.env.XDG_DATA_HOME .. "/nvim/")
					end
					if file and linenr then
						vim.cmd.vsplit(file)
						vim.api.nvim_win_set_cursor(0, { tonumber(linenr), 0 })
					else
						vim.cmd("vertical wincmd f")
					end
				end, { desc = "go to location", buffer = vim.api.nvim_win_get_buf(win) })
			end,
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		-- dependencies:
		-- 	MunifTanjim/nui.nvim
		keys = {
			{
				"<M-x>",
				"<Cmd>Noice dismiss<CR>",
				mode = { "n", "i", "c", "v" },
				desc = "Dismiss all notifications",
			},
		},
		opts = {
			presets = {
				bottom_search = true,         -- use a classic bottom cmdline for search
				command_palette = true,       -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				lsp_doc_border = true,        -- add a border to hover docs and signature help
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
			markdown = {
				hover = {
					["|(%S-)|"] = vim.cmd.help, -- vim help links
					["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
					["%%(%S-) "] = require("utils.cppman").open,
					["@c ([^ .]+)"] = require("utils.cppman").open,
					["\\<a href=\"([^>]*)\">.-\\</a>"] = function(match)
						local url = "https://gcc.gnu.org/onlinedocs/libstdc++/latest-doxygen/" .. match
						vim.fn.jobstart({
							"xdg-open",
							url,
						}, { detach = true })
					end,
				},
				highlights = {
					["\\<a href=\"[^>]*\">(.-)\\</a>"] = "@markup.link",
					["|%S-|"] = "@markup.link",
					["@%S+"] = "@keyword",
					["@c [^ .]+"] = "@function",
					["^%s*(Parameters:)"] = "Title",
					["^%s*(Return:)"] = "Title",
					["^%s*(See also:)"] = "Title",
					["{%S-}"] = "@keyword",
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
						find = "^%s*$",
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "notify",
						kind = "info",
						find = "^tabout%.nvim: No parser found for filetype",
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "notify",
						kind = "warn",
						find = "^Heads up! This layout changed the list order,\nso `up` goes down and `down` goes up.",
					},
					opts = { skip = true },
				},
			},
		},
	},
}
