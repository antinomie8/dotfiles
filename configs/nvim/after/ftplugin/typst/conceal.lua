local buf = vim.api.nvim_get_current_buf()

local function char_at(row, col)
	local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	if not line or col < 0 or col >= #line then return nil end
	return line:sub(col + 1, col + 1)
end

local function conceal_char_at(row, col, ns, char)
	if char_at(row, col) ~= char then return end

	vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
		end_row = row,
		end_col = col + 1,
		conceal = "",
		priority = 103,
		hl_group = "TypstConcealDelims",
	})
end

-- conceal delimiters
local ns_delims = vim.api.nvim_create_namespace("typst_delims")

local nodes = {
	math = { symbol = "$", node = "math" },
	emph = { symbol = "_", node = "emph" },
	strong = { symbol = "*", node = "strong" },
}
for capture, opts in pairs(nodes) do
	local ok, query = pcall(
		vim.treesitter.query.parse,
		"typst",
		string.format("((%s) @%s)", opts.node, capture, capture)
	)
	if not ok then
		vim.notify("Typst conceal: failed to compile query", vim.log.levels.ERROR)
		return
	end

	nodes[capture].query = query
end

local function conceal_delims(first, last)
	vim.api.nvim_buf_clear_namespace(buf, ns_delims, first, last)

	local ok, parser = pcall(vim.treesitter.get_parser, buf, "typst")
	if not ok or not parser then return end
	local tree = parser:parse()[1]
	if not tree then return end
	local root = tree:root()

	for capture, opts in pairs(nodes) do
		for id, node in opts.query:iter_captures(root, buf, first, last) do
			if opts.query.captures[id] == capture then
				local srow, scol, erow, ecol = node:range()
				conceal_char_at(srow, scol, ns_delims, opts.symbol)
				conceal_char_at(erow, ecol - 1, ns_delims, opts.symbol)
			end
		end
	end
end

vim.api.nvim_buf_attach(0, false, {
	on_lines = function(_, _, _, first, last)
		conceal_delims(first, last)
	end,
})

conceal_delims(0, -1)

-- conceal symbols
local ns_math = vim.api.nvim_create_namespace("typst_math_conceal")

local functions = require("static.lang.typst.calls")
local subscripts = require("static.lang.typst.subscripts")
local superscripts = require("static.lang.typst.superscripts")
local symbols = require("static.lang.typst.symbols")

-- returns a list of {row=, col=, ch=} for each character in the buffer span
local function get_char_positions_in_range(bufnr, sr, sc, er, ec)
	local lines = vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
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

-- apply a per-character extmark on the given range
local function conceal_at_positions(bufnr, sr, sc, er, ec, text, hl)
	local positions = get_char_positions_in_range(buf, sr, sc, er, ec)

	-- cover the entire span first (hides underlying text)
	pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_math, sr, sc, {
		end_row = er,
		end_col = ec,
		conceal = "",
		hl_group = hl,
		priority = 101,
	})

	-- split translated text into characters
	local tch = vim.fn.split(text, "\\zs")
	local n = math.min(#tch, #positions)
	for i = 1, n do
		local pos = positions[i]
		if pos then
			pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_math, pos.row, pos.col, {
				end_row = pos.row,
				end_col = pos.col + #pos.ch,
				conceal = tch[i],
				hl_group = hl,
				priority = 102,
			})
		end
	end
end

local function conceal_node_recursively(node, map, rec, hl)
	local sr, sc, er, ec = node:range()
	local concealed = rec(node, map)
	conceal_at_positions(buf, sr, sc, er, ec, concealed, hl)
end

local queries = {
	symbols = vim.treesitter.query.parse(
		"typst",
		[[
			(
				(field) @symbol
				(#not-has-ancestor? @symbol field )
			)
			(
				(ident) @symbol
				(#has-ancestor? @symbol math )
				(#not-has-ancestor? @symbol field)
			)
			(
				attach . (ident) @symbol
				(#not-has-ancestor? @symbol field)
			)
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
			(
				(call)
				@function
				(#has-ancestor? @function math)
				(#not-has-ancestor? @function attach)
			)
		]]
	),
}

local function math_conceal(first, last)
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "typst")
	if not ok or not parser then return end
	local tree = parser:parse()[1]
	if not tree then return end
	local root = tree:root()

	vim.api.nvim_buf_clear_namespace(buf, ns_math, first, last)

	-- subscripts and superscripts
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
					for i = 1, #text + 1 do
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
		elseif node:type() == "number" or node:type() == "string" then
			local text = vim.treesitter.get_node_text(node, 0, {})
			for i = 1, #text + 1 do
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
		elseif node:child_count() > 0 then
			for child in node:iter_children() do
				concealed = concealed .. conceal_script(child, map)
			end
		else
			local text = vim.treesitter.get_node_text(node, 0, {})
			if not (text == "(" or text == ")") then
				for i = 1, #text do
					concealed = concealed .. (map[text:sub(i, i)] or text:sub(i, i))
				end
			end
		end
		return concealed
	end

	for _, node in queries.scripts.subscripts:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		if
			#vim.api.nvim_buf_get_extmarks(buf, ns_math, { sr, sc }, { er, ec }, { overlap = true }) <= 1
		then
			conceal_char_at(sr, sc - 1, ns_math, "_")
			conceal_node_recursively(node, subscripts, conceal_script, "TypstConcealScript")
		end
	end

	for _, node in queries.scripts.superscripts:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		if
			#vim.api.nvim_buf_get_extmarks(buf, ns_math, { sr, sc }, { er, ec }, { overlap = true }) <= 1
		then
			conceal_char_at(sr, sc - 1, ns_math, "^")
			conceal_node_recursively(node, superscripts, conceal_script, "TypstConcealScript")
		end
	end

	-- function calls
	for _, node in queries.functions:iter_captures(root, buf, first, last) do
		local _, _, er, ec = node:range()
		local child = node:field("item")[1]
		if child then
			local name = vim.treesitter.get_node_text(child, 0, {})
			local repl = functions[name]
			if repl and repl.left and repl.right then
				local text = vim.treesitter.get_node_text(node, 0, {})
				text = text:match("^" .. name .. "%((.*)%)$") or text
				local child_sr, child_sc, child_er, child_ec = child:range()
				if char_at(child_er, child_ec) == "(" then
					child_ec = child_ec + 1
				end
				conceal_at_positions(buf, child_sr, child_sc, child_er, child_ec, repl.left, "TypstConcealSurround")
				conceal_at_positions(buf, er, ec - 1, er, ec, repl.right, "TypstConcealSurround")
			elseif repl then
				local function conceal_text(node, map)
					local concealed = ""
					if node:type() == "letter" then
						local text = vim.treesitter.get_node_text(node, 0, {})
						local repl = map[text]
						if repl then
							return repl
						else
							return text
						end
					elseif node:child_count() then
						for child in node:iter_children() do
							concealed = concealed .. conceal_text(child, map)
						end
					else
						local text = vim.treesitter.get_node_text(node, 0, {})
						return text
					end
					return concealed
				end
				conceal_node_recursively(node, repl, conceal_text, "TypstConcealLetters")
			end
		end
	end

	-- symbols
	for _, node, metadata in queries.symbols:iter_captures(root, buf, first, last) do
		local sr, sc, er, ec = node:range()
		local text = vim.treesitter.get_node_text(node, 0, { metadata = metadata })
		local repl = symbols[text]
		if repl and
			#vim.api.nvim_buf_get_extmarks(buf, ns_math, { sr, sc }, { er, ec }, { overlap = true }) <= 1
		then
			conceal_at_positions(buf, sr, sc, er, ec, repl.cchar, repl.hl)
		end
	end
end

vim.api.nvim_buf_attach(buf, false, {
	on_lines = function(_, _, _, first, last) math_conceal(first, last) end,
})

math_conceal(0, -1)
