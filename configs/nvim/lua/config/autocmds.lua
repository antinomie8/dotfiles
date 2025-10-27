-- show the cursorline in the active buffer only, and hide for some filetypes
vim.api.nvim_create_autocmd("WinLeave", {
	callback = function() vim.opt_local.cursorline = false end,
})
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function(event)
		local exclude = { "alpha", "neo-tree-popup" }
		if not vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
			vim.opt_local.cursorline = true
		end
	end,
})

-- hide the cursor in chosen filetypes
vim.api.nvim_create_autocmd({ "BufEnter", "CmdlineLeave" }, {
	callback = function(event)
		local enable = {
			"aerial",
			"alpha",
			"dap-float",
			"diff",
			"DiffviewFiles",
			"dropbar_menu",
			"neo-tree",
			"noice",
			"trouble",
			"undotree",
			"yazi",
		}
		if vim.tbl_contains(enable, vim.bo[event.buf].filetype) then
			vim.cmd("hi Cursor blend=100")
		else
			vim.cmd("hi Cursor blend=0")
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "alpha", "undotree" },
	callback = function() vim.cmd("hi Cursor blend=100") end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function() vim.cmd("hi Cursor blend=0") end,
})
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		if vim.fn.getcmdscreenpos() == 2 then
			vim.schedule(function() vim.cmd("hi Cursor blend=0") end)
		end
	end,
})

-- toggle some options in terminals and darken their background
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.winhighlight = "Normal:TerminalBackground"
		vim.cmd("startinsert")
	end,
})

-- Auto create dir when saving a file if some of the intermediate directories do not exist
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"checkhealth",
		"dap-float",
		"diff",
		"grug-far",
		"help",
		"lspinfo",
		"notify",
		"toggleterm",
		"tutor",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last location when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
			return
		end
		vim.b[buf].last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		if mark[1] > 0 then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "mail", "text", "plaintex", "typst", "gitcommit", "markdown", "tex" },
	callback = function()
		if not vim.bo.modifiable then return end

		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.opt_local.formatoptions = "t,c,q,n,2,j"

		vim.keymap.set(
			"i",
			"<C-l>",
			"<c-g>u<Esc>[s1z=`]a<c-g>u",
			{ desc = "Correct last spelling mistake", buffer = true }
		)
		vim.keymap.set(
			"i",
			"<C-r>",
			"<c-g>u<Esc>[szg`]a<c-g>u",
			{ desc = "Add last word marked as misspelled to dictionnary", buffer = true }
		)
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local exclude = { "mail", "text", "plaintex", "typst", "gitcommit", "markdown", "tex" }
		if not vim.tbl_contains(exclude, vim.bo.filetype) then
			vim.opt.formatoptions = "c,q,n,2,j"
		end
	end,
})

-- Reset terminal mode when quitting Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function() vim.fn.jobstart({ "reset" }) end,
})

-- Reset terminal settings after any terminal closes
vim.api.nvim_create_autocmd("TermClose", {
	pattern = "*",
	callback = function() vim.cmd("silent! !stty sane") end,
})
