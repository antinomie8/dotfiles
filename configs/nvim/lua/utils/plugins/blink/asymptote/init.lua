--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

local data = require("utils.plugins.blink.asymptote.data")

-- `opts` table comes from `sources.providers.your_provider.opts`
-- You may also accept a second argument `config`, to get the full
-- `sources.providers.your_provider` table
function source.new(opts)
	-- vim.validate("your-source.opts.some_option", opts.some_option, { "string" })
	-- vim.validate("your-source.opts.optional_option", opts.optional_option, { "string" }, true)

	local self = setmetatable({}, { __index = source })
	self.opts = opts
	return self
end

-- (Optional) Enable the source in specific contexts only
function source:enabled() return vim.bo.filetype == "asymptote" end

-- (Optional) Non-alphanumeric characters that trigger the source
-- function source:get_trigger_characters() return { "." } end

function source:get_completions(ctx, callback)
	-- ctx (context) contains the current keyword, cursor position, bufnr, etc.

	-- You should never filter items based on the keyword, since blink.cmp will
	-- do this for you

	-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItem
	--- @type lsp.CompletionItem[]
	local items = {}
	for cat, tbl in pairs(data) do
		for _, name in ipairs(tbl) do
			--- @type lsp.CompletionItem
			local item = {
				-- Label of the item in the UI
				label = name,
				-- (Optional) Item kind, where `Function` and `Method` will receive
				-- auto brackets automatically
				kind = require("blink.cmp.types").CompletionItemKind[tbl.kind or "Function"],

				-- (Optional) Text to fuzzy match against
				-- filterText = name,
				-- (Optional) Text to use for sorting. You may use a layout like
				-- 'aaaa', 'aaab', 'aaac', ... to control the order of the items
				-- sortText = name,

				-- Text to be inserted when accepting the item using ONE of:
				--
				-- (Recommended) Control the exact range of text that will be replaced
				-- textEdit = {
				-- 	newText = name,
				-- 	range = {
				-- 		-- 0-indexed line and character, end-exclusive
				-- 		start = { line = 1, character = 0 },
				-- 		["end"] = { line = 1, character = 1 },
				-- 	},
				-- },
				-- Or get blink.cmp to guess the range to replace for you. Use this only
				-- when inserting *exclusively* alphanumeric characters. Any symbols will
				-- trigger complicated guessing logic in blink.cmp that may not give the
				-- result you're expecting
				-- Note that blink.cmp will use `label` when omitting both `insertText` and `textEdit`
				-- insertText = name,
				-- May be Snippet or PlainText. Works with both `textEdit` and `insertText`
				-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#snippet_syntax
				insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,

				-- There are some other fields you may want to explore which are blink.cmp
				-- specific, such as `score_offset` (blink.cmp.CompletionItem)
			}
			table.insert(items, item)
		end
	end

	-- The callback _MUST_ be called at least once. The first time it's called,
	-- blink.cmp will show the results in the completion menu. Subsequent calls
	-- will append the results to the menu to support streaming results.
	--
	-- NOTE: blink.cmp will mutate the items you return, so you must vim.deepcopy them
	-- before returning if you want to re-use them in the future (such as for caching)
	callback({
		items = items,
		-- Whether blink.cmp should request items when deleting characters
		-- from the keyword (e.g. "foo|" -> "fo|")
		-- Note that any non-alphanumeric characters will always request
		-- new items (excluding `-` and `_`)
		is_incomplete_backward = false,
		-- Whether blink.cmp should request items when adding characters
		-- to the keyword (e.g. "fo|" -> "foo|")
		-- Note that any non-alphanumeric characters will always request
		-- new items (excluding `-` and `_`)
		is_incomplete_forward = false,
	})

	-- (Optional) Return a function which cancels the request
	-- If you have long running requests, it's essential you support cancellation
	return function() end
end

-- (Optional) Before accepting the item or showing documentation, blink.cmp will call this function
-- so you may avoid calculating expensive fields (e.g. documentation) for only when they're actually needed
-- Note only some fields may be resolved lazily. You may check the LSP capabilities for a complete list:
-- `textDocument.completion.completionItem.resolveSupport`
-- At the time of writing: 'documentation', 'detail', 'additionalTextEdits', 'command', 'data'
function source:resolve(item, callback)
	item = vim.deepcopy(item)

	-- Shown in the documentation window (<C-space> when menu open by default)
	item.documentation = {
		kind = "markdown",
		value = "# Foo\n\nBar",
	}

	-- Additional edits to make to the document, such as for auto-imports
	-- item.additionalTextEdits = {
	-- 	{
	-- 		newText = "foo",
	-- 		range = {
	-- 			start = { line = 0, character = 0 },
	-- 			["end"] = { line = 0, character = 0 },
	-- 		},
	-- 	},
	-- }

	callback(item)
end

-- (Optional) Called immediately after applying the item's textEdit/insertText
-- Only useful when you want to customize how items are accepted,
-- beyond what's possible with `textEdit` and `additionalTextEdits`
function source:execute(ctx, item, callback, default_implementation)
	-- When you provide an `execute` function, your source must handle the execution
	-- of the item itself, but you may use the default implementation at any time
	default_implementation()

	-- The callback _MUST_ be called once
	callback()
end

return source
