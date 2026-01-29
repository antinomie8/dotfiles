vim.cmd([[
	aunmenu   PopUp
	autocmd!  nvim.popupmenu
	anoremenu PopUp.Inspect     <Cmd>Inspect<CR>
	amenu     PopUp.-1-         <NOP>
	anoremenu PopUp.Definition  <Cmd>lua vim.lsp.buf.definition()<CR>
	anoremenu PopUp.References  <Cmd>lua require("snacks.picker").lsp_references()<CR>
	nnoremenu PopUp.Back        <C-t>
]])

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
	pattern = "*",
	group = group,
	callback = function()
		if vim.lsp.get_clients({ bufnr = 0 })[1] then
			vim.cmd([[
				amenu enable PopUp.-1-
				amenu enable PopUp.Definition
				amenu enable PopUp.References
			]])
		else
			vim.cmd([[
				amenu disable PopUp.-1-
				amenu disable PopUp.Definition
				amenu disable PopUp.References
			]])
		end
	end,
})
