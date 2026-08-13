local ls = require("utils.snippets.luasnip")
local s, t, i, d, fmt = ls.s, ls.t, ls.i, ls.d, ls.fmt
local helpers = require("utils.snippets.helpers")
local line_begin = helpers.line_begin
local get_visual = helpers.get_visual
local events = require("luasnip.util.events")

local function ensure_figures_import()
	local target_pkg = "@local/figures:1.0.0"
	local insert_str = '#import "' .. target_pkg .. '": *'

	local buf = vim.api.nvim_get_current_buf()

	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok or not parser then
		vim.notify("No Treesitter parser found for the current buffer.", vim.log.levels.WARN)
		return
	end

	local lang = parser:lang()
	local tree = parser:parse()[1]
	local root = tree:root()

	local query_str = [[
		(import
			import: (string) @pkg_string
		) @import_statement
	]]

	local ok_query, query = pcall(vim.treesitter.query.parse, lang, query_str)
	if not ok_query then
		vim.notify("Failed to parse Treesitter query for language: " .. lang, vim.log.levels.ERROR)
		return
	end

	local is_imported = false
	local last_import_row = -1

	for id, node in query:iter_captures(root, buf, 0, -1) do
		local capture_name = query.captures[id]

		if capture_name == "pkg_string" then
			local text = vim.treesitter.get_node_text(node, buf)

			local cleaned_text = text:gsub('^["\']', ""):gsub('["\']$', "")

			if cleaned_text == target_pkg then
				is_imported = true
				break
			end
		elseif capture_name == "import_statement" then
			local _, _, end_row, _ = node:range()
			if end_row > last_import_row then
				last_import_row = end_row
			end
		end
	end

	if is_imported then return end

	if last_import_row ~= -1 then
		vim.api.nvim_buf_set_lines(buf, last_import_row + 1, last_import_row + 1, false, { insert_str })
	else
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, { insert_str, "" })
	end
end

return {
	s({ trig = "!F", dscr = "figure", cond = line_begin, snippetType = "autosnippet" },
		{ t({ "#figure(", "\t" }), d(1, get_visual), t({ "", ")" }) }),
	s({ trig = "!C", dscr = "canvas", snippetType = "autosnippet" },
		fmt([[
			#figure(
				canvas({
					import figures.drawing: *

					<>
				}),
			)
      ]], { i(1) }),
		{ callbacks = { [-1] = { [events.enter] = ensure_figures_import } } }
	),
	s({ trig = "!Z", dscr = "complex plane", snippetType = "autosnippet" },
		fmt([[
			#figure(
				complex-plane({
					import figures.drawing: *

					<>
				}),
			)
      ]],
			{ i(1) }),
		{ callbacks = { [-1] = { [events.enter] = ensure_figures_import } } }
	),
	s({ trig = "!G", dscr = "function graph", snippetType = "autosnippet" },
		fmt(
			[[
				#figure(
					graph({
						import figures.function-graph: *
						import calc: *

						plot.add(domain: (-2, 7), x =>> <>)
					}),
				)
      ]],
			{ i(1) }
		),
		{ callbacks = { [-1] = { [events.enter] = ensure_figures_import } } }
	),
	s({ trig = "!trig", dscr = "unit circle", snippetType = "autosnippet" },
		fmt([[
			#figure(
				trig-circle({
					import figures.drawing: *

					<>
				}),
			)
      ]],
			{ i(1) }),
		{ callbacks = { [-1] = { [events.enter] = ensure_figures_import } } }
	),
}
