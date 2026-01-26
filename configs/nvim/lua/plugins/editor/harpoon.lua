local function toggle_picker(harpoon_files)
	local items = {}
	for i, harpoon_item in ipairs(harpoon_files.items) do
		local path = harpoon_item.value
		local item = {
			idx = i,
			text = path,
			file = path,
			name = path,
		}
		table.insert(items, item)
	end

	require("snacks").picker({
		title = "Harpoon",
		source = "harpoon",
		items = items,
	})
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	-- dependencies:
	-- 	nvim-lua/plenary.nvim
	keys = {
		{
			"<M-a>",
			function() require("harpoon"):list():add() end,
			desc = "Add file to Harpoon",
		},
		{
			"<M-h>",
			function() toggle_picker(require("harpoon"):list()) end,
			desc = "Toggle Harpoon ui",
		},

		{ "<M-p>", function() require("harpoon"):list():select(1) end },
		{ "<M-m>", function() require("harpoon"):list():select(2) end },
		{ "<M-l>", function() require("harpoon"):list():select(3) end },
		{ "<M-o>", function() require("harpoon"):list():select(4) end },
	},
	opts = {
		settings = {
			save_on_toggle = true,
			sync_on_ui_close = true,
			key = function() return vim.uv.cwd() end,
		},
	},
}
