local buf = vim.api.nvim_get_current_buf()

local function get_typst_root()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, 3, false)

	for lnum, line in ipairs(lines) do
		local typst_root = line:match("^//%s*typst%s+root:%s*(.*)%s*$")
		if typst_root then
			vim.b[buf].typst_root = typst_root
			return
		end
	end
end

local function set_typst_root()
	get_typst_root()

	local root_path = vim.b[buf].typst_root
	if not root_path then return end
	if not vim.uv.fs_stat(root_path) then return end

	local root_buf = vim.fn.bufadd(root_path)
	vim.fn.bufload(root_buf)
	vim.bo[root_buf].buflisted = false

	local client = vim.lsp.get_clients({ bufnr = buf, name = "tinymist" })[1]
	if client then
		client:exec_cmd({
			title = "pin",
			command = "tinymist.pinMain",
			arguments = { vim.api.nvim_buf_get_name(root_buf) },
		}, { bufnr = buf })
		client:exec_cmd({
			title = "exportpdf",
			command = "tinymist.exportPdf",
			arguments = { vim.api.nvim_buf_get_name(root_buf) },
		}, { bufnr = buf })
	else
		vim.defer_fn(set_typst_root, 1000)
		vim.notify("No LSP client found for tinymist in buffer " .. root_buf, vim.log.levels.WARN)
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = set_typst_root,
	once = true,
	buffer = buf,
})
