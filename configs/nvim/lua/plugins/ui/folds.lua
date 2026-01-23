return {
	"kevinhwang91/nvim-ufo",
	-- dependencies:
	--  kevinhwang91/promise-async
	event = "VeryLazy",
	opts = {
		open_fold_hl_timeout = 150,
		fold_virt_text_handler = function(virtText, foldstart, foldend, width, truncate)
			local virtual_text = {}
			local fold_line_count = foldend - foldstart
			local buf_line_count = vim.api.nvim_buf_line_count(0)
			local suffix = (" %d  %d%% ···"):format(fold_line_count, math.floor(fold_line_count / buf_line_count * 100))
			local suffix_width = vim.fn.strdisplaywidth(suffix)
			local target_width = width - suffix_width
			local current_width = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if target_width > current_width + chunkWidth then
					table.insert(virtual_text, chunk)
				else
					chunkText = truncate(chunkText, target_width - current_width)
					local hlGroup = chunk[2]
					table.insert(virtual_text, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					-- str width returned from truncate() may less than 2nd argument, need padding
					if current_width + chunkWidth < target_width then
						suffix = string.rep("·", target_width - current_width - chunkWidth) .. suffix
					end
					break
				end
				current_width = current_width + chunkWidth
			end
			table.insert(virtual_text, { string.rep("·", target_width - current_width), "Folded" })
			table.insert(virtual_text, { suffix, "Folded" })
			return virtual_text
		end,

		provider_selector = function()
			return { "treesitter", "indent" }
		end,
	},
}
