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
				local eq_pos = anchor:find(" =[^=]")

				if eq_pos then
					local indent = anchor:match("^%s*")
					local align_spaces = string.rep(" ", eq_pos + 2 - #indent)

					for k = i + 1, block_end do
						local stripped = lines[k]:gsub("^(%s*)\t\t ", "%1" .. align_spaces)
						lines[k] = stripped
					end
				elseif anchor:find("=$") then
					local indent = anchor:match("^%s*")
					local align_spaces
					local keyword = anchor:match("^" .. indent .. "[a-z]* ")
					if keyword then
						align_spaces = string.rep(" ", #keyword)
					else
						align_spaces = "\t"
					end

					for k = i + 1, block_end do
						local stripped = lines[k]:gsub("^(%s*)\t\t ", "%1" .. align_spaces)
						lines[k] = stripped
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
