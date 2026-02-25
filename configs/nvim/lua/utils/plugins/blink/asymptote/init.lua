---@module 'blink.cmp'
---@class blink.cmp.Source
local source = {}

local kinds = require("blink.cmp.types").CompletionItemKind

local function map_kind(k)
	if k == "function" then return kinds.Function end
	if k == "struct" then return kinds.Class end
	if k == "variable" then return kinds.Variable end
	return kinds.Text
end

function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = opts or {}

	-- load symbols once
	local function get_current_dir()
		local source = debug.getinfo(1, "S").source
		source = source:sub(2) -- remove '@'
		return vim.fn.fnamemodify(source, ":h")
	end

	local function load_json(filename)
		local dir = get_current_dir()
		local path = dir .. "/" .. filename

		local lines = vim.fn.readfile(path)
		return vim.json.decode(table.concat(lines, "\n"))
	end

	self.symbols = load_json("geometry.json")

	-- signature lookup
	self.signatures = {}

	for _, sym in ipairs(self.symbols) do
		if sym.kind == "function" and sym.signature then
			self.signatures[sym.name] = sym
		end
	end

	return self
end

function source:enabled()
	return vim.bo.filetype == "asymptote"
end

function source:get_trigger_characters()
	return { "(", "," }
end

local function get_call_info(ctx)
	local ts = vim.treesitter
	local bufnr = ctx.bufnr or 0

	local parser = ts.get_parser(bufnr)
	if not parser then return end

	local tree = parser:parse()[1]
	local root = tree:root()

	local row, col = ctx.cursor[1] - 1, ctx.cursor[2]

	local node = root:named_descendant_for_range(row, col, row, col)
	if not node then return end

	-- climb to call_expression
	while node do
		if node:type() == "call_expression" then
			break
		end
		node = node:parent()
	end

	if not node then return end

	-- function name
	local fn_node = node:field("function")[1]
	if not fn_node then return end

	local name = vim.treesitter.get_node_text(fn_node, bufnr)

	-- arguments
	local args_node = node:field("arguments")[1]
	if not args_node then
		return { name = name }
	end

	local args = {}
	for child in args_node:iter_children() do
		if child:named() then
			table.insert(args, child)
		end
	end

	local active = 0
	for i, arg in ipairs(args) do
		local sr, sc, er, ec = arg:range()
		if
			(row > sr or (row == sr and col >= sc))
			and
			(row < er or (row == er and col <= ec))
		then
			active = i
			break
		end
	end

	return { name = name, args = args, active = active }
end

function source:get_signature_help(ctx, callback)
	local call = get_call_info(ctx)

	if not call then
		callback(nil)
		return
	end

	---@diagnostic disable-next-line: undefined-field
	local sym = self.signatures[call.name]
	if not sym then
		callback(nil)
		return
	end

	local params = {}
	local param_string = sym.signature:match("%((.*)%)") or ""

	for p in param_string:gmatch("[^,]+") do
		table.insert(params, { label = vim.trim(p) })
	end

	callback({
		signatures = {
			{
				label = sym.type .. " " .. sym.signature,
				documentation = {
					kind = "markdown",
					value = sym.documentation or "",
				},
				parameters = params,
			},
		},
		activeSignature = 0,
		activeParameter = math.min(call.active or 0, #params - 1),
	})
end

function source:get_completions(ctx, callback)
	local items = {}

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	-- replace current keyword range
	local start_col = col
	while start_col > 0 and line:sub(start_col, start_col):match("[%w_]") do
		start_col = start_col - 1
	end

	local replace_range = {
		start = { line = row - 1, character = start_col },
		["end"] = { line = row - 1, character = col },
	}

	for _, sym in ipairs(self.symbols) do
		table.insert(items, {
			label = sym.name,
			kind = map_kind(sym.kind),

			-- shown on right side of menu
			detail = sym.type .. " " .. sym.signature,

			textEdit = {
				newText = sym.name,
				range = replace_range,
			},

			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,

			-- lazy-loaded later
			data = sym,
		})
	end

	callback({
		items = items,
		is_incomplete_forward = false,
		is_incomplete_backward = false,
	})
end

function source:resolve(item, callback)
	item = vim.deepcopy(item)

	local sym = item.data
	if sym and sym.documentation then
		item.documentation = {
			kind = "markdown",
			value = sym.documentation,
		}
	end

	callback(item)
end

return source
