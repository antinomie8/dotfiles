return {
	format = function(self, ctx, lines, callback)
		local lines = vim.deepcopy(lines)
		for lnum, line in ipairs(lines) do
			lines[lnum] = line:gsub("(%a)%-%- ", "%1--"):gsub(" ^ ^", "^^")
		end
		callback(nil, lines)
	end,
}
