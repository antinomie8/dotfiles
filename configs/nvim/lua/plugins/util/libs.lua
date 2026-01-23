local M = {}

local libs = {
	"nvim-lua/plenary.nvim",
	"nvim-neotest/nvim-nio",
	"MunifTanjim/nui.nvim",
	"kevinhwang91/promise-async",
	"b0o/schemastore.nvim",
}

for _, lib in ipairs(libs) do
	table.insert(M, { lib, lazy = true })
end

return M
