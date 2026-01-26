return {
	"mbbill/undotree",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "Undotree" },
	keys = {
		{ "<leader>tr", "<Cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
	},
	config = function()
		vim.g.undotree_HelpLine = 0
		vim.g.undotree_StatusLine = 0
		vim.g.undotree_SplitWidth = 30
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.g.undotree_HighlightChangedText = 0
		vim.g.undotree_TreeNodeShape = "●"
		vim.g.undotree_TreeVertShape = "│"
		vim.g.undotree_TreeSplitShape = "/"
		vim.g.undotree_TreeReturnShape = "\\"
		vim.g.undotree_SignAdded = "▎"
		vim.g.undotree_SignChanged = "▎"
		vim.g.undotree_SignDeleted = ""
		vim.g.undotree_SignDeletedEnd = ""
		vim.g.undotree_HighlightSyntaxAdd = "diffAdded"
		vim.g.undotree_HighlightSyntaxDel = "diffDeleted"
		vim.g.undotree_HighlightSyntaxChange = "diffChanged"
		vim.g.undotree_CustomUndotreeCmd = "vertical 32 new"
		vim.g.undotree_CustomDiffpanelCmd = "belowright 12 new"
		vim.g.undotree_DisabledFiletypes = { "snacks_picker_input" }
		vim.g.undotree_CustomMap = function()
			vim.keymap.set("n", "J", "<Plug>UndotreePreviousState", { buffer = true })
			vim.keymap.set("n", "K", "<Plug>UndotreeNextState", { buffer = true })
		end
	end,
}
