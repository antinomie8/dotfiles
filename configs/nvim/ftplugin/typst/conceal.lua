local buf = vim.api.nvim_get_current_buf()
local ns_math = vim.api.nvim_create_namespace("typst_math_conceal")
local ns_overflow = vim.api.nvim_create_namespace("typst_math_conceal_overflow")
local overflow_specs = {}

local functions = require("static.lang.typst.calls")
local subscripts = require("static.lang.typst.subscripts")
local superscripts = require("static.lang.typst.superscripts")
local symbols = require("static.lang.typst.symbols")
local emojis = require("static.lang.typst.emojis")
local shorthands = require("static.lang.typst.shorthands")

---@param row integer
---@param col integer
---@return string?
local function char_at(row, col)
	local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	if not line or col < 0 or col >= #line then return nil end
	return line:sub(col + 1, col + 1)
end

---returns a table with the character and position of each char in the given range
---@param sr integer
---@param sc integer
---@param er integer
---@param ec integer
---@return {row: integer, col: integer, ch: string}[]
local function get_char_positions_in_range(sr, sc, er, ec)
	local lines = vim.api.nvim_buf_get_text(buf, sr, sc, er, ec, {})
	local pos = {}
	local row = sr
	for i, line in ipairs(lines) do
		local chars = vim.fn.split(line, "\\zs")
		local col = (i == 1) and sc or 0
		for _, ch in ipairs(chars) do
			table.insert(pos, { row = row, col = col, ch = ch })
			col = col + #ch -- byte-length increment
		end
		if i < #lines then
			row = row + 1
		end
	end
	return pos
end

---apply a per-character extmark on the given range
---@param sr integer
---@param sc integer
---@param er integer
---@param ec integer
---@param conceal_text string
---@param hl string?
local function conceal_at_positions(sr, sc, er, ec, conceal_text, hl)
	local positions = get_char_positions_in_range(sr, sc, er, ec)

	-- cover the entire span first (hides underlying text)
	pcall(vim.api.nvim_buf_set_extmark, buf, ns_math, sr, sc, {
		end_row = er,
		end_col = ec,
		conceal = "",
		hl_group = hl,
		priority = 101,
	})

	local tch = vim.fn.split(conceal_text, "\\zs")
	if #tch == 0 then return end

	-- conceal extmarks only support a single replacement character, so spread
	-- them one-per-hidden-char; any overflow is appended as inline virt_text
	local overflow
	if #positions == 0 then
		overflow = conceal_text
	else
		local n = math.min(#tch, #positions)
		for i = 1, n do
			local pos = positions[i]
			pcall(vim.api.nvim_buf_set_extmark, buf, ns_math, pos.row, pos.col, {
				end_row = pos.row,
				end_col = pos.col + #pos.ch,
				conceal = tch[i],
				hl_group = hl,
				priority = 102,
			})
		end
		if #tch > #positions then
			overflow = table.concat(tch, "", #positions + 1, #tch)
			local last = positions[#positions]
			sr, sc, er, ec = last.row, last.col + #last.ch, last.row, last.col + #last.ch
		end
	end
	if overflow then
		local chunk = { overflow }
		if hl then chunk = { overflow, hl } end
		local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, ns_overflow, sr, sc, {
			virt_text = { chunk },
			virt_text_pos = "inline",
			priority = 102,
		})
		if ok and id then
			table.insert(overflow_specs, { id = id, text = overflow, hl = hl, shown = true })
		end
	end
end

---hide/show overflow virt_text depending on cursor position and 'concealcursor'
local function sync_overflow()
	if not vim.api.nvim_buf_is_valid(buf) then return end
	local ccur = vim.api.nvim_get_option_value("concealcursor", { win = 0 })
	local m = vim.api.nvim_get_mode().mode:sub(1, 1)
	if m == "V" or m == "\22" or m == "\19" then m = "v" end
	local hidden = ccur:find(m, 1, true) ~= nil
	local crow = vim.api.nvim_win_get_cursor(0)[1] - 1
	for _, spec in ipairs(overflow_specs) do
		local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns_overflow, spec.id, {})
		if pos[1] then
			local show = not (hidden and pos[1] == crow)
			if show ~= spec.shown then
				local opts = { id = spec.id, virt_text_pos = "inline", priority = 102 }
				if show then
					opts.virt_text = { spec.hl and { spec.text, spec.hl } or { spec.text } }
				end
				pcall(vim.api.nvim_buf_set_extmark, buf, ns_overflow, pos[1], pos[2], opts)
				spec.shown = show
			end
		end
	end
end

---@param node TSNode
---@param map table<string, string>
---@param rec_cb fun(node: TSNode, map: table<string, string>)
---@param hl string
local function conceal_node_recursively(node, map, rec_cb, hl)
	local sr, sc, er, ec = node:range()
	local concealed = rec_cb(node, map)
	conceal_at_positions(sr, sc, er, ec, concealed, hl)
end

local queries = {
	symbols = vim.treesitter.query.parse(
		"typst",
		[[
			((field) @sym
				(#not-has-ancestor? @sym field ))
			((ident) @sym
				(#has-ancestor? @sym math)
				(#not-has-ancestor? @sym field))
			(attach . (ident) @sym
				(#not-has-ancestor? @sym field))
		]]
	),
	scripts = {
		subscripts = vim.treesitter.query.parse(
			"typst",
			[[
				(attach sub: (_) @sub)
			]]
		),
		superscripts = vim.treesitter.query.parse(
			"typst",
			[[
				(attach sup: (_) @sup)
			]]
		),
	},
	functions = vim.treesitter.query.parse(
		"typst",
		[[
			((call
				item: (ident) @func)
				(#has-ancestor? @func math)
				(#not-has-ancestor? @func attach))
		]]
	),
	shorthands = vim.treesitter.query.parse(
		"typst",
		[[
			((shorthand) @shorthand
				(#has-ancestor? @shorthand math)
				(#not-has-ancestor? @shorthand attach))
			((symbol) @shorthand ; for ||
				(#has-ancestor? @shorthand math)
				(#not-has-ancestor? @shorthand attach))
		]]
	),
	primes = vim.treesitter.query.parse(
		"typst",
		[[
			((prime) @prime
				(#has-ancestor? @prime math)
				(#not-has-ancestor? @prime attach))
		]]
	),
	vocab = vim.treesitter.query.parse(
		"typst",
		[[
			(code
				.(call
					.item: (ident) @func_name
						.(group
							.(string).).).
				(#eq? @func_name vocab)) @vocab
		]]
	),
	emojis = vim.treesitter.query.parse(
		"typst",
		[[
			((code
				.
				(field)
				.) @emoji
				(#lua-match? @emoji "^#emoji%.")
				(#gsub! @emoji "^#emoji%.(.*)" "%1"))
		]]
	),
}

---@param first integer
---@param last integer
local function conceal_math(first, last)
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "typst")
	if not ok or not parser then return end
	local tree = parser:parse()[1]
	if not tree then return end
	local root = tree:root()

	vim.api.nvim_buf_clear_namespace(buf, ns_math, first, last)
	vim.api.nvim_buf_clear_namespace(buf, ns_overflow, first, last)

	-- drop overflow specs whose extmark was just cleared
	local live = {}
	for _, spec in ipairs(overflow_specs) do
		if #vim.api.nvim_buf_get_extmark_by_id(buf, ns_overflow, spec.id, {}) > 0 then
			table.insert(live, spec)
		end
	end
	overflow_specs = live

	-- subscripts and superscripts
	---@param node TSNode?
	---@param map table<string, string>
	local function conceal_script(node, map)
		if not node then return "" end

		local concealed = ""
		if node:type() == "field" or node:type() == "ident" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			local repl = map[text]
			if repl then
				return repl
			else
				local repl = symbols[text]
				if repl then
					return repl.cchar
				else
					for i = 1, #text do
						concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
					end
				end
			end
		elseif node:type() == "letter" or node:type() == "symbol" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			local repl = map[text]
			if repl then
				return repl
			else
				return text
			end
		elseif node:type() == "number" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			for i = 1, #text do
				concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
			end
		elseif node:type() == "string" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			for i = 2, #text - 1 do
				concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
			end
		elseif node:type() == "fraction" then
			concealed = concealed .. conceal_script(node:named_child(0), map)
			concealed = concealed .. (map["/"] or "")
			concealed = concealed .. conceal_script(node:named_child(1), map)
		elseif node:type() == "call" then
			concealed = concealed .. conceal_script(node:named_child(0), map)
			concealed = concealed .. (map["("] or "(")
			concealed = concealed .. conceal_script(node:named_child(1), map)
			concealed = concealed .. (map[")"] or ")")
		elseif node:type() == "shorthand" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			local repl = map[text]
			if repl then
				return repl
			else
				local repl = shorthands[text]
				if repl then
					return repl
				else
					for i = 1, #text do
						concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
					end
				end
			end
		elseif node:type() == "prime" then
			local text = vim.treesitter.get_node_text(node, 0)
			local primes = text:match("[^']*('+)")
			local repl = primes and shorthands[primes] or ""
			concealed = conceal_script(node:child(0), map) .. repl
		elseif node:child_count() > 0 then
			for child, field in node:iter_children() do
				if field ~= "sub" and field ~= "sup" then
					concealed = concealed .. conceal_script(child, map)
				end
			end
		elseif node:named() then
			local text = vim.treesitter.get_node_text(node, 0, {})
			for i = 1, #text do
				concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
			end
		end
		return concealed
	end

	for _, node in queries.scripts.subscripts:iter_captures(root, buf, first, last) do
		conceal_node_recursively(node, subscripts, conceal_script, "TypstConcealScript")
	end
	for _, node in queries.scripts.superscripts:iter_captures(root, buf, first, last) do
		conceal_node_recursively(node, superscripts, conceal_script, "TypstConcealScript")
	end

	-- function calls
	for _, node in queries.functions:iter_captures(root, buf, first, last) do
		local name = vim.treesitter.get_node_text(node, 0, {})
		local sibling, parent = node:next_named_sibling(), node:parent()
		if not sibling or not parent then goto continue end
		local sr, sc, er, ec = parent:range()
		local repl = functions[name]

		if repl and repl.left and repl.right then
			local child_sr, child_sc, child_er, child_ec = node:range()
			if char_at(child_er, child_ec) == "(" then
				child_ec = child_ec + 1
			end
			conceal_at_positions(child_sr, child_sc, child_er, child_ec, repl.left, "TypstConcealSurround")
			conceal_at_positions(er, ec - 1, er, ec, repl.right, "TypstConcealSurround")
		elseif repl then
			if sibling:has_error() then return end -- in case of unclosed delimiter causing the whole document to get in the node
			local string_node = sibling:named_child(0)
			if string_node and (string_node:type() == "string" or string_node:type() == "letter") then
				local text = vim.treesitter.get_node_text(string_node, buf)
				local concealed = ""
				for i = 1, #text do
					local char = text:sub(i, i)
					concealed = concealed .. (repl[char] or char)
				end
				conceal_at_positions(sr, sc, er, ec, concealed, "TypstConcealLetter")
			end
		end
		::continue::
	end

	-- symbols
	for _, node, metadata in queries.symbols:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		local text = vim.treesitter.get_node_text(node, 0, { metadata = metadata })
		local repl = symbols[text]
		if repl and
			#vim.api.nvim_buf_get_extmarks(buf, ns_math, { sr, sc }, { er, ec - 1 }, { overlap = true }) == 0
		then
			conceal_at_positions(sr, sc, er, ec, repl.cchar, repl.hl)
		end
	end

	-- shorthands
	for _, node, metadata in queries.shorthands:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		local text = vim.treesitter.get_node_text(node, 0, { metadata = metadata })
		local repl = shorthands[text]
		if repl then
			conceal_at_positions(sr, sc, er, ec, repl, "@operator.typst")
		end
	end

	-- primes
	for _, node, metadata in queries.primes:iter_captures(root, buf, first, last) do
		local sr, sc = node:range()
		local text = vim.treesitter.get_node_text(node, 0, { metadata = metadata })
		local offset, primes = text:match("([^']*)('+)")
		local repl = primes and shorthands[primes] or nil
		if repl then
			conceal_at_positions(sr, sc + #offset, sr, sc + #offset + #primes, repl, "@operator.typst")
		end
	end

	-- vocab
	for _, match, metadata in queries.vocab:iter_matches(root, buf, first, last) do
		for id, nodes in pairs(match) do
			local name = queries.vocab.captures[id]
			if name == "vocab" then
				for _, node in ipairs(nodes) do
					local sr, sc, er, ec = node:range()
					local word_node = node:child(1):child(1):child(1) --[[@as TSNode]]
					local word = vim.treesitter.get_node_text(word_node, 0, { metadata = metadata })
					word = word:sub(2, #word - 1) -- strip quotes
					conceal_at_positions(sr, sc, er, ec, word, "TypstConcealVocab")
				end
			end
		end
	end

	-- emojis
	for id, node, metadata in queries.emojis:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		local text = metadata[id].text
		local cchar = emojis[text]
		if cchar then
			conceal_at_positions(sr, sc, er, ec, cchar)
		end
	end

	sync_overflow()
end

vim.api.nvim_buf_attach(buf, false, {
	on_lines = function(_, _, _, first, last)
		conceal_math(first, last)
	end,
})

local augroup = vim.api.nvim_create_augroup("typst_math_conceal_overflow_" .. buf, { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "BufEnter", "WinEnter" }, {
	group = augroup,
	buffer = buf,
	callback = function()
		sync_overflow()
	end,
})

conceal_math(0, -1)

-- keymaps
vim.keymap.set("n", "<localleader>m", function()
	conceal_math(0, -1)
end, { desc = "Update conceal extmarks", buffer = true })
vim.keymap.set("v", "<localleader>m", function()
	-- '< and '> marks give previous selection instead of current
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	conceal_math(start_line - 1, end_line)
end, { desc = "Update conceal extmarks", buffer = true })
