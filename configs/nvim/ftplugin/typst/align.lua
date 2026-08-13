local ALIGN_OPS = {
	["="] = true,
	["<"] = true,
	[">"] = true,
	["<="] = true,
	[">="] = true,
}

local function error(msg, level)
	vim.notify(msg, level and level or vim.log.levels.ERROR,
		{ title = "typst align", icon = "" })
end

--- Build an indent string that reaches display column `col` (0-indexed),
--- respecting the buffer's 'expandtab'/'tabstop'.
local function indent_to_col(bufnr, col)
	if vim.bo[bufnr].expandtab then
		return string.rep(" ", col)
	end
	local ts = vim.bo[bufnr].tabstop
	local tabs = math.floor(col / ts)
	local spaces = col % ts
	return string.rep("\t", tabs) .. string.rep(" ", spaces)
end

--- Display column (0-indexed) of byte-column `bytecol` on `line`, expanding
--- tabs at `tabstop`.
local function visual_col(line, bytecol, tabstop)
	local vcol = 0
	for i = 1, bytecol do
		local c = line:sub(i, i)
		if c == "\t" then
			vcol = vcol + (tabstop - (vcol % tabstop))
		else
			vcol = vcol + 1
		end
	end
	return vcol
end

---@param node TSNode?
---@return TSNode? formula
local function find_top_formula(node)
	while node do
		if node and node:type() == "formula" then
			return node
		end
		node = node:parent()
	end
	return nil
end

--- Collect, in document order, the direct children of `formula` that
--- represent a top-level relation operator: `=`, `<`, `>` are `symbol`
--- nodes, while `<=` and `>=` are a single `shorthand` node.
---@param formula TSNode
---@param bufnr integer
---@return TSNode[]
local function collect_relation_symbols(formula, bufnr)
	local matches = {}
	for _, child in ipairs(formula:named_children()) do
		local ctype = child:type()
		if ctype == "symbol" or ctype == "shorthand" then
			local text = vim.treesitter.get_node_text(child, bufnr)
			if ALIGN_OPS[text] then
				table.insert(matches, child)
			end
		end
	end
	return matches
end

--- Walk backward from (row, col) (0-indexed, col = byte offset) over
--- whitespace (spaces, tabs, and line breaks) and return the position right
--- after the last non-whitespace character, i.e. the start of the
--- whitespace "gap" that immediately precedes (row, col).
local function gap_start(bufnr, row, col)
	local r, c = row, col
	while true do
		local pr, pc
		if c > 0 then
			pr, pc = r, c - 1
		elseif r > 0 then
			local prev_line = vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1] or ""
			pr, pc = r - 1, #prev_line
		else
			return r, c -- start of buffer
		end

		local line = vim.api.nvim_buf_get_lines(bufnr, pr, pr + 1, false)[1] or ""
		local ch = line:sub(pc + 1, pc + 1) -- char AT position pc (0-indexed) -> 1-indexed pc+1
		if ch == "" or ch:match("%s") then
			-- either the (virtual) newline boundary, or real whitespace: keep going
			r, c = pr, pc
		else
			return r, c
		end
	end
end

--- Align the Typst math relation chain the cursor is currently inside.
local function align_math_equation()
	local bufnr = vim.api.nvim_get_current_buf()

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "typst")
	if not ok or not parser then
		error("no typst tree-sitter parser for this buffer")
		return
	end
	parser:parse()

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
	if not node then
		error("no tree-sitter node at cursor")
		return
	end

	local formula = find_top_formula(node)
	if not formula then
		error("cursor is not inside a math formula", vim.log.levels.WARN)
		return
	end

	local matches = collect_relation_symbols(formula, bufnr)
	if #matches == 0 then
		error("no top-level " .. table.concat(ALIGN_OPS, ", ") .. " found in this formula", vim.log.levels.WARN)
		return
	end

	local tabstop = vim.bo[bufnr].tabstop

	-- Alignment target: the display column of the FIRST match. That's where
	-- every "&" (including the one on the first line) will end up sitting.
	local first_sr, first_sc = matches[1]:range()
	local first_line = vim.api.nvim_buf_get_lines(bufnr, first_sr, first_sr + 1, false)[1]
	local target_col = visual_col(first_line, first_sc, tabstop)

	-- Every line gets a trailing " \" -- including the very last one, right
	-- before the closing "$" -- not just the ones with another relation
	-- following them. Anchor this on the formula node's own end position
	-- (not the end of the physical line): if the whole equation is on one
	-- line, e.g. "$ a = b = c $", the line itself continues past the
	-- formula with " $", so appending at end-of-line would land the
	-- backslash after the closing "$".
	local _, _, formula_end_row, formula_end_col = formula:range()

	-- If the closing "$" sits directly against the formula with no space
	-- (e.g. "$a = b$"), "e \$" would parse as an escaped literal dollar
	-- sign rather than a line break followed by the delimiter -- pad with
	-- a trailing space in that case.
	local formula_end_line = vim.api.nvim_buf_get_lines(bufnr, formula_end_row, formula_end_row + 1, false)[1] or ""
	local next_char = formula_end_line:sub(formula_end_col + 1, formula_end_col + 1)
	local backslash_repl = (next_char == "$") and { " \\ " } or { " \\" }

	vim.api.nvim_buf_set_text(
		bufnr, formula_end_row, formula_end_col, formula_end_row, formula_end_col, backslash_repl
	)

	-- Edit from the last match to the first so that earlier positions
	-- (which we already captured via :range()) stay valid.
	for idx = #matches, 1, -1 do
		local sr, sc = matches[idx]:range()

		if idx == 1 then
			-- First relation: just drop an "& " in front of it, don't touch
			-- whatever separates it from the previous token.
			vim.api.nvim_buf_set_text(bufnr, sr, sc, sr, sc, { "& " })
		else
			-- Every other relation: replace the whitespace gap in front of it
			-- (which may be a single space if everything is still on one line,
			-- or a newline + indent if the line was already broken) with a
			-- line-continuation and a freshly aligned "& ".
			local gr, gc = gap_start(bufnr, sr, sc)
			local indent = indent_to_col(bufnr, target_col)
			vim.api.nvim_buf_set_text(bufnr, gr, gc, sr, sc, { " \\", indent .. "& " })
		end
	end

	error(string.format("aligned %d relation%s", #matches, #matches == 1 and "" or "s"), vim.log.levels.INFO)
end

-- keymaps
vim.keymap.set("n", "<localleader>=", function()
	align_math_equation()
end, { buffer = true, desc = "Align Typst math relation chain" })
