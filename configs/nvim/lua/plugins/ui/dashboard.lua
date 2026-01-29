return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			width = 60,
			pane_gap = 4,                                                             -- empty columns between vertical panes
			autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
			preset = {
				keys = {
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "e", desc = "File explorer", action = ":Neotree toggle" },
					{ icon = "󰱼 ", key = "f", desc = "Find File", action = ":lua require('snacks.picker').files()" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":lua require('snacks.picker').grep()" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":lua require('snacks.picker').recent()" },
					{ icon = "󰁯 ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
				header = [[
       ████ ██████           █████      ██                    
      ███████████             █████                            
      █████████ ███████████████████ ███   ███████████  
     █████████  ███    █████████████ █████ ██████████████  
    █████████ ██████████ █████████ █████ █████ ████ █████  
  ███████████ ███    ███ █████████ █████ █████ ████ █████ 
 ██████  █████████████████████ ████ █████ █████ ████ ██████]],
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				-- { section = "startup" },
			},
		},
		styles = {
			dashboard = {
				bo = {
					filetype = "dashboard",
				},
			},
		},
	},
}
