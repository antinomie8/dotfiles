local M = {}

local libs = {
	"nvim-lua/plenary.nvim",
	"nvim-neotest/nvim-nio",
	"MunifTanjim/nui.nvim",
	"kevinhwang91/promise-async",

	-- completion sources
	"archie-judd/blink-cmp-words",
	"mayromr/blink-cmp-dap",
}

for _, lib in ipairs(libs) do
	table.insert(M, { lib, lazy = true })
end

return M
