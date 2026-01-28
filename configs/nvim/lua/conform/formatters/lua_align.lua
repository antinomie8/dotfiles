return {
	format = function(self, ctx, lines, callback)
		local lines = vim.deepcopy(lines)
		local i = #lines

		while i >= 1 do
			local line = lines[i]

			if line:match("^%s*\t\t ") then
				local block_end = i

				while i >= 1 and lines[i]:match("^%s*\t\t ") do
					i = i - 1
				end

				local anchor = lines[i]
				local eq_pos = anchor:find("=")

				if eq_pos and eq_pos >= 30 and anchor:match("^%s*local ") then
					local indent = anchor:match("^(%s*)")

					for k = i + 1, block_end do
						local stripped = lines[k]:gsub("^%s*", "      ")
						lines[k] = indent .. stripped
					end
				elseif eq_pos then
					local indent = anchor:match("^(%s*)")
					local align_spaces = string.rep(" ", eq_pos + 1 - #indent)

					for k = i + 1, block_end do
						local stripped = lines[k]:gsub("^%s*\t\t ", "")
						lines[k] = indent .. align_spaces .. stripped
					end
				else
					for k = i + 1, block_end do
						local stripped = lines[k]:gsub("^(%s*)\t ", "%1")
						lines[k] = stripped
					end
				end
			end

			i = i - 1
		end

		callback(nil, lines)
	end,
}
