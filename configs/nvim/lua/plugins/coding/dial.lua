return {
	"monaqa/dial.nvim",
	keys = {
		{ "<C-a>",  function() require("dial.map").manipulate("increment", "normal") end,  mode = "n", desc = "Increment" },
		{ "<C-x>",  function() require("dial.map").manipulate("decrement", "normal") end,  mode = "n", desc = "Decrement" },
		{ "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n", desc = "Increment" },
		{ "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n", desc = "Decrement" },
		{ "<C-a>",  function() require("dial.map").manipulate("increment", "visual") end,  mode = "v", desc = "Increment" },
		{ "<C-x>",  function() require("dial.map").manipulate("decrement", "visual") end,  mode = "v", desc = "Decrement" },
		{ "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "Increment" },
		{ "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "Decrement" },
	},
	config = function()
		local augend = require("dial.augend")

		local default = {
			augend.integer.alias.decimal, -- nonnegative decimal number
			augend.integer.alias.hex,  -- nonnegative hex number
			augend.date.new({
				pattern = "%d/%m/%Y",
				default_kind = "day",
			}),
			augend.date.new({
				pattern = "%d-%m-%Y",
				default_kind = "day",
			}),
			augend.date.new({
				pattern = "%d/%m",
				default_kind = "day",
				only_valid = true,
			}),
			augend.date.new({
				pattern = "%M:%H",
				default_kind = "day",
				only_valid = true,
			}),

			augend.constant.new({
				elements = { "and", "or" },
				word = true,
				cyclic = true,
			}),
			augend.constant.new({
				elements = { "&&", "||" },
				word = false,
				cyclic = true,
			}),
			augend.constant.new({
				elements = { "true", "false" },
				word = true,
				cyclic = true,
			}),
			augend.constant.new({
				elements = { "True", "False" },
				word = true,
				cyclic = true,
			}),
			augend.integer.new({
				radix = 16,
				prefix = "0x",
				natural = true,
				case = "upper",
			}),
			augend.hexcolor.new({
				case = "upper",
			}),
		}

		local function extend(arg) return vim.list_extend(arg, default) end

		require("dial.config").augends:register_group({
			default = default,
		})
		require("dial.config").augends:on_filetype({
			markdown = extend({
				augend.constant.new({
					elements = { "- [ ]", "- [x]" },
					word = false,
					cyclic = true,
				}),
			}),
		})
	end,
}
