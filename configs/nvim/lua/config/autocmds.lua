-- show the cursorline in the active buffer only, and hide for some filetypes
vim.api.nvim_create_autocmd("WinLeave", {
	callback = function() vim.opt_local.cursorline = false end,
})
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function(event)
		local exclude = { "dashboard", "neo-tree-popup" }
		if not vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
			vim.opt_local.cursorline = true
		end
	end,
})

-- hide the cursor in chosen filetypes
vim.api.nvim_create_autocmd({ "BufEnter", "CmdlineLeave" }, {
	callback = function(event)
		local cursor_hidden = {
			"aerial",
			"dap-float",
			"diff",
			"DiffviewFiles",
			"dropbar_menu",
			"gitgraph",
			"neo-tree",
			"notmuch-threads",
			"dashboard",
			"trouble",
			"undotree",
			"yazi",
		}
		local ft_ignore = { "noice", "notify", "blink-cmp-menu" }
		if vim.tbl_contains(ft_ignore, vim.bo[event.buf].filetype) then
			return
		elseif vim.tbl_contains(cursor_hidden, vim.bo[event.buf].filetype) then
			vim.cmd("hi Cursor blend=100")
		else
			vim.cmd("hi Cursor blend=0")
		end
	end,
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

-- toggle some options and hide the cursor on enter
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "notmuch-threads", "gitgraph", "undotree" },
	callback = function()
		vim.cmd("hi Cursor blend=100")
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.sidescrolloff = 0
		vim.opt_local.signcolumn = "no"
	end,
})

-- darken terminal background and begin in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(event)
		if vim.api.nvim_buf_get_name(event.buf):match("yazi$") then
			return
		end
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

-- don't spellcheck urls and email addresses
local ns = vim.api.nvim_create_namespace("nospell_urls")

local function apply_nospell_extmarks(buf, first, last)
	local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
	vim.api.nvim_buf_clear_namespace(buf, ns, first, last)

	local nospell_patterns = {
		[[%w+://[%w%-%._~:/%?#%[%]@!$&'()*+,;=%%]+]], -- url
		[[[%w%.%+%-_]+@[%w%-]+%.%a+]],                -- email
	}

	for linenr, line in ipairs(lines) do
		for _, pattern in ipairs(nospell_patterns) do
			for s, e in line:gmatch("()" .. pattern .. "()") do
				vim.api.nvim_buf_set_extmark(buf, ns, first + linenr - 1, s - 1, {
					end_col = e - 1,
					hl_mode = "combine",
					spell = false,
					priority = 101,
				})
			end
		end
	end
end

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "spell",
	callback = function(args)
		local buf = args.buf

		if not vim.wo.spell then return end
		if vim.b[buf].spell_ignore_attached then return end
		vim.b[buf].spell_ignore_attached = true

		apply_nospell_extmarks(buf, 0, -1)
		vim.api.nvim_buf_attach(buf, false, {
			on_lines = function(_, _, _, first, last)
				if vim.wo.spell then
					apply_nospell_extmarks(buf, first, last)
				else
					vim.b[buf].spell_ignore_attached = false
					return true
				end
			end,
		})
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "mail", "text", "plaintex", "typst", "gitcommit", "markdown", "tex" },
	callback = function()
		if not vim.opt_local.modifiable:get() then return end

		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.api.nvim_exec_autocmds("OptionSet", { pattern = "spell" })
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

-- update &spellfile when &spelllang changes
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "spelllang",
	callback = function()
		local spell_dir = vim.fn.stdpath("config") .. "/spell"
		local langs = vim.opt.spelllang:get()

		local add_files = {}
		for _, lang in ipairs(langs) do
			local filename = string.format("%s/%s.utf-8.add", spell_dir, lang)
			table.insert(add_files, filename)
		end

		vim.opt.spellfile = table.concat(add_files, ",")
	end,
})

-- change titlestring
vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		local ft_icon = {
			["man"] = "󱚊",
			["mail"] = "",
			["notmuch-threads"] = "",
		}
		local ft_ignore = { "noice", "notify", "blink-cmp-menu" }
		if vim.tbl_contains(ft_ignore, vim.bo[event.buf].filetype) then
			return
		else
			vim.opt_local.titlestring = (ft_icon[vim.bo[event.buf].filetype] or "") .. " %t"
		end
	end,
})

-- remove terminal padding on leave
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		if not vim.env.NVIM and not vim.env.TMUX and not vim.env.YAZI_ID and vim.env.KITTY_LISTEN_ON then
			vim.system({ "kitty", "@", "--to", vim.env.KITTY_LISTEN_ON, "set-spacing", "padding=20" })
		end
	end,
})
