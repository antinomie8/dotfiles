return {
	format = function(self, ctx, lines, callback)
		local out_lines = vim.deepcopy(lines)
		for lnum, line in ipairs(out_lines) do
			out_lines[lnum] = line:gsub("(%a)%-%- ", "%1--"):gsub(" ^ ^", "^^")
		end
		callback(nil, out_lines)
	end,
}
