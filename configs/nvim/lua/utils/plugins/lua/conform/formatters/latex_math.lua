return {
	format = function(self, ctx, lines, callback)
		local lines = vim.deepcopy(lines)
		local bufnr = ctx.buf

		local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
		if lang ~= "latex" then return end

		local parser = vim.treesitter.get_parser(bufnr, lang)
		if not parser then return end

		local tree = parser:parse()[1]
		if not tree then return end
		local root = tree:root()

		local query = vim.treesitter.query.parse(
			lang,
			[[
				(inline_formula) @inline
				(displayed_equation) @display
			]]
		)

		local offset = {}

		for id, node in query:iter_captures(root, bufnr, 0, -1) do
			local name = query.captures[id]
			local sr, sc, er, ec = node:range()
			sc = sc + (offset[sr + 1] or 0)
			ec = ec + (offset[er + 1] or 0)

			if name == "inline" then
				if sr == er then
					local l = lines[sr + 1]
					-- convert $...$
					if l:sub(sc + 1, sc + 1) == "$" and l:sub(ec, ec) == "$" then
						lines[sr + 1] = l:sub(1, sc) .. "\\(" .. l:sub(sc + 2, ec - 1) .. "\\)" .. l:sub(ec + 1)
						offset[sr + 1] = (offset[sr + 1] or 0) + 2
					end
				else
					local first, last = lines[sr + 1], lines[er + 1]
					-- convert $...$ across lines
					if first:sub(sc + 1, sc + 1) == "$" and last:sub(ec, ec) == "$" then
						lines[sr + 1] = first:sub(1, sc) .. "\\(" .. first:sub(sc + 2)
						lines[er + 1] = last:sub(1, ec - 1) .. "\\)" .. last:sub(ec + 1)
						offset[sr + 1] = (offset[sr + 1] or 0) + 1
						offset[er + 1] = (offset[er + 1] or 0) + 1
					end
				end
			elseif name == "display" then
				if sr == er then
					local l = lines[sr + 1]
					-- convert $$...$$
					if l:sub(sc + 1, sc + 2) == "$$" and l:sub(ec - 1, ec) == "$$" then
						lines[sr + 1] = l:sub(1, sc) .. "\\[" .. l:sub(sc + 3, ec - 2) .. "\\]" .. l:sub(ec + 1)
					end
				else
					local first, last = lines[sr + 1], lines[er + 1]
					-- convert $...$ across lines
					if first:sub(sc + 1, sc + 2) == "$$" and last:sub(ec - 1, ec) == "$$" then
						lines[sr + 1] = first:sub(1, sc) .. "\\[" .. first:sub(sc + 3)
						lines[er + 1] = last:sub(1, ec - 2) .. "\\]" .. last:sub(ec + 1)
					end
				end
			end
		end

		callback(nil, lines)
	end,
}
