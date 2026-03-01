return {
	format = function(self, ctx, lines, callback)
		local lines = vim.deepcopy(lines)

		for i, line in ipairs(lines) do
			local indent, content = line:match("^(%s*)(.*)$")

			if indent then
				local spaces = indent:gsub("\t", "  ")
				local space_count = #spaces

				local tabs = math.floor(space_count / vim.bo.shiftwidth)

				lines[i] = string.rep("\t", tabs) .. content
			else
				lines[i] = line
			end
		end

		callback(nil, lines)
	end,
}
