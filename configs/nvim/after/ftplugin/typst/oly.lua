local buf = vim.api.nvim_get_current_buf()
local ns_metadata = vim.api.nvim_create_namespace("metadata")
local ns_hrule = vim.api.nvim_create_namespace("hrule")

local function highlight_metadata(first, last)
	vim.api.nvim_buf_clear_namespace(buf, ns_metadata, first, last)

	local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)

	local valid_keywords = {
		title = true,
		source = true,
		topic = true,
		tags = true,
		url = true,
		desc = true,
		author = true,
		difficulty = true,
	}

	for lnum, line in ipairs(lines) do
		lnum = lnum + first

		if line:match("^%s*$") or line:match("^/%*") then
			goto continue
		end

		local whitespace, keyword, _ = line:match("^(%s*)([a-zA-Z]+):%s*(.*)")
		if not keyword then
			if vim.api.nvim_win_get_cursor(0)[1] == lnum then
				goto continue
			end
			break
		end

		-- Highlight full line
		vim.api.nvim_buf_set_extmark(buf, ns_metadata, lnum - 1, #whitespace + #keyword + 1, {
			end_col = #line,
			hl_group = "Text",
			spell = false,
			priority = 101,
		})

		-- Highlight keyword
		local group = valid_keywords[keyword] and "Identifier" or "Error"
		vim.api.nvim_buf_set_extmark(buf, ns_metadata, lnum - 1, #whitespace, {
			end_col = #whitespace + #keyword,
			hl_group = group,
			spell = false,
			priority = 101,
		})
		valid_keywords[keyword] = false

		-- Highlight colon
		local colon_col = line:find(":")
		if colon_col then
			vim.api.nvim_buf_set_extmark(buf, ns_metadata, lnum - 1, colon_col - 1, {
				end_col = colon_col,
				hl_group = "Special",
				priority = 101,
			})
		end

		-- Highlight brackets and commas
		for i = 1, #line do
			local char = line:sub(i, i)
			if char == "[" or char == "]" or char == "," then
				vim.api.nvim_buf_set_extmark(buf, ns_metadata, lnum - 1, i - 1, {
					end_col = i,
					hl_group = "Delimiter",
					priority = 101,
				})
			end
		end
		::continue::
	end
end

local function highlight_hrule(first, last)
	vim.api.nvim_buf_clear_namespace(buf, ns_hrule, first, last)

	local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)

	for lnum, line in ipairs(lines) do
		if line:match("^#hrule%s*$") then
			vim.api.nvim_buf_set_extmark(buf, ns_hrule, first + lnum - 1, 0, {
				virt_text = { { string.rep("─", 80), "Indent" } },
				virt_text_pos = "overlay",
				hl_mode = "combine",
			})
		end
	end
end

if vim.env.OLY and not vim.b[buf].oly_highlight then
	vim.b[buf].oly_highlight = true
	vim.b[buf].typst_root = vim.fn.expand("%:p:h") .. "/preview.typ"

	vim.cmd.cd(vim.fn.expand("%:p:h"))

	highlight_metadata(0, -1)
	highlight_hrule(0, -1)

	vim.api.nvim_buf_attach(buf, false, {
		on_lines = function(_, _, _, first, last)
			if last < 10 then
				highlight_metadata(first, last)
			end
			highlight_hrule(first, last)
		end,
	})
end
