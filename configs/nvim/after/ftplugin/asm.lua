vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- assembles and links the current file
vim.api.nvim_buf_create_user_command(0, "Assemble", function()
	local filename = vim.fn.expand("%:r")
	vim.system(
		{ "nasm", "-f", "elf64", "-o", filename .. ".o", vim.fn.expand("%") },
		{ text = true },
		function(obj)
			print(obj.stderr)
			if obj.signal == 0 then
				vim.system(
					{ "ld", "-o", filename .. ".out", filename .. ".o" },
					{ text = true },
					function(obj) print(obj.stderr) end
				)
				vim.system(
					{ "rm", filename .. ".o" },
					{},
					function(_)
						vim.notify("Assembling completed", vim.log.levels.INFO, { title = "Assembling", icon = " " })
					end
				)
			end
		end)
end, {})

vim.keymap.set(
	"n",
	"<localleader>as",
	"<Cmd>Assemble<CR>",
	{ desc = "Assemble and link the current file", buffer = true }
)
