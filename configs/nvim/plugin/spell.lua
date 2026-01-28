-- don't spellcheck urls and email addresses
local group = vim.api.nvim_create_augroup("IgnoreSpell", { clear = true })
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
	group = group,
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
	callback = function(args)
		if not vim.opt_local.modifiable:get() then return end

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
