local ALIGN_OPS = {
	["="] = true,
	["<"] = true,
	[">"] = true,
	["<="] = true,
	[">="] = true,
}

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

--- Walk up from `node` and return the nearest ancestor (or `node` itself)
--- whose type is "formula" and whose parent is "math". That is the
--- outermost formula of the enclosing `$ ... $` (or `$ ... $` block),
--- which is exactly the node we want to scan for top-level relation
--- operators.
local function find_top_formula(node)
	local cur = node
	while cur do
		local parent = cur:parent()
		if parent and parent:type() == "math" and cur:type() == "formula" then
			return cur
		end
		cur = parent
	end
	return nil
end

--- Collect, in document order, the direct children of `formula` that
--- represent a top-level relation operator: `=`, `<`, `>` are `symbol`
--- nodes, while `<=` and `>=` are a single `shorthand` node.
local function collect_relation_symbols(formula, bufnr)
	local matches = {}
	for i = 0, formula:named_child_count() - 1 do
		local child = formula:named_child(i)
		local ctype = child:type()
		if ctype == "symbol" or ctype == "shorthand" then
			local text = vim.treesitter.get_node_text(child, bufnr)
			if (ctype == "symbol" or ctype == "shorthand") and ALIGN_OPS[text] then
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
		vim.notify("typst_align: no typst tree-sitter parser for this buffer", vim.log.levels.ERROR)
		return
	end
	parser:parse()

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
	if not node then
		vim.notify("typst_align: no tree-sitter node at cursor", vim.log.levels.ERROR)
		return
	end

	local formula = find_top_formula(node)
	if not formula then
		vim.notify("typst_align: cursor is not inside a math formula", vim.log.levels.WARN)
		return
	end

	local matches = collect_relation_symbols(formula, bufnr)
	if #matches == 0 then
		vim.notify("typst_align: no top-level =, <, >, <=, >= found in this formula", vim.log.levels.WARN)
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

	vim.notify(string.format("typst_align: aligned %d relation(s)", #matches), vim.log.levels.INFO)
end

--- Does `line` begin with optional whitespace, "&", optional whitespace,
--- then one of the relation operators?
local function line_starts_with_align_op(line)
	for _, op in ipairs(ALIGN_OPS) do
		if line:match("^%s*&%s*" .. op) then
			return true
		end
	end
	return false
end

--- Is the position (row, col) inside a "math" node?
local function pos_in_math(bufnr, row, col)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "typst")
	if not ok or not parser then return false end
	parser:parse()
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
	local cur = node
	while cur do
		if cur:type() == "math" then return true end
		cur = cur:parent()
	end
	return false
end

--- 0-indexed byte column of the first non-whitespace character on `line`
--- (0 if the line is entirely whitespace/empty).
local function first_nonws_col(line)
	local first = line:find("%S")
	return first and (first - 1) or 0
end

--- Is `row` the last line of the top-level formula enclosing it (i.e. the
--- last line of content before the math block's closing "$")?
local function is_last_line_of_math(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local col = first_nonws_col(line)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "typst")
	if not ok or not parser then return false end
	parser:parse()
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
	if not node then return false end
	local formula = find_top_formula(node)
	if not formula then return false end
	local _, _, end_row = formula:range()
	return row == end_row
end

--- Trigger for `o`: current line ends with "\", OR begins with "&<op>",
--- OR is the last line of the enclosing math block.
local function should_open_below(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local col = first_nonws_col(line)
	if not pos_in_math(bufnr, row, col) then return false end
	if line:match("\\%s*$") then return true end
	if line_starts_with_align_op(line) then return true end
	if is_last_line_of_math(bufnr, row) then return true end
	return false
end

--- Trigger for `O`: current line begins with "&<op>" (nothing else).
local function should_open_above(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	if not line_starts_with_align_op(line) then return false end
	local col = first_nonws_col(line)
	return pos_in_math(bufnr, row, col)
end

--- If `row` doesn't already end (ignoring trailing whitespace) with a
--- backslash, trim trailing whitespace and append " \".
local function ensure_trailing_backslash(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	if line:match("\\%s*$") then
		return -- already there
	end
	local trimmed = line:gsub("%s+$", "")
	vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { trimmed .. " \\" })
end

--- Insert a "<indent>&= | \" line at buffer row `insert_row` (0-indexed,
--- text pushed down to make room) and return the text before the cursor
--- placeholder ("<indent>&= ").
local function open_align_line(bufnr, insert_row, indent)
	local before_cursor = indent .. "&= "
	local after_cursor = " \\"
	vim.api.nvim_buf_set_lines(bufnr, insert_row, insert_row, false, { before_cursor .. after_cursor })
	return before_cursor
end

--- `o`/`O` replacement, math-aware:
---   o: if the current line ends with "\", begins with "&<op>", or is the
---      last line of the enclosing math block, ensure it ends with " \"
---      and open a "&= | \" continuation line BELOW it (| = cursor).
---   O: if the current line begins with "&<op>", open a "&= | \" line
---      ABOVE it instead (no backslash bookkeeping on the current line).
--- Anywhere else, falls back to plain o / O.
local function smart_open(direction)
	local bufnr = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local indent = line:match("^%s*") or ""

	if direction == "below" and should_open_below(bufnr, row) then
		ensure_trailing_backslash(bufnr, row)
		local before_cursor = open_align_line(bufnr, row + 1, indent)
		vim.api.nvim_win_set_cursor(0, { row + 2, #before_cursor })
		vim.cmd.startinsert()
		return
	end

	if direction == "above" and should_open_above(bufnr, row) then
		local before_cursor = open_align_line(bufnr, row, indent)
		vim.api.nvim_win_set_cursor(0, { row + 1, #before_cursor })
		vim.cmd.startinsert()
		return
	end

	-- Not a math alignment context: defer to Neovim's real o / O so indent
	-- expressions, autopairs, etc. all behave normally.
	if direction == "above" then
		vim.api.nvim_feedkeys("O", "n", false)
	else
		vim.api.nvim_feedkeys("o", "n", false)
	end
end

-- keymaps
vim.keymap.set("n", "<localleader>=", function()
	align_math_equation()
end, { buffer = true, desc = "Align Typst math relation chain" })

vim.keymap.set("n", "o", function() smart_open("below") end,
	{ buffer = true, desc = "Open line below" })
vim.keymap.set("n", "O", function() smart_open("above") end,
	{ buffer = true, desc = "Open line above" })
