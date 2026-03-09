-- export pdf
local function compile(handler)
	local filepath = vim.b.typst_root and vim.b.typst_root or vim.api.nvim_buf_get_name(0)
	local client = vim.lsp.get_clients({ name = "tinymist" })[1]
	if client then
		client:exec_cmd({
				title = "exportpdf",
				command = "tinymist.exportPdf",
				arguments = { filepath },
			}, nil,
			handler)
	else
		vim.notify("Tinymist is not running !", vim.log.levels.ERROR, { title = "Generate PDF", icon = "" })
	end
end

vim.api.nvim_buf_create_user_command(0, "ExportPdf", function() compile() end, {})
vim.keymap.set("n", "<localleader>c", "<Cmd>ExportPdf<CR>", { desc = "Export pdf", buffer = true })

-- open pdf
local function open(path, opts)
	local pdf_path
	if path then
		pdf_path = path
	else
		local filepath = vim.b.typst_root and vim.b.typst_root or vim.api.nvim_buf_get_name(0)
		pdf_path = filepath:gsub("%.typ$", ".pdf")
	end
  require("utils.pdf").open(pdf_path, opts)
end
vim.api.nvim_buf_create_user_command(0, "OpenPdf", function(arg)
	open(arg.fargs[1], { silent = arg.bang })
end, { nargs = "?", bang = true })
vim.keymap.set("n", "<localleader>o", "<Cmd>OpenPdf<CR>", { desc = "Open pdf", buffer = true })

-- compile and open
vim.keymap.set("n", "<localleader>p", function()
	compile(function(err, result, ctx)
		open(result.path)
	end)
end, { desc = "Export and open pdf", buffer = true })
