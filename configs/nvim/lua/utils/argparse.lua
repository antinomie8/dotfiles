local M = {}

---splits the input string like a shell would
---@param input string
---@return string[] words input split by whitespace, with respect to quoting and escaping
function M.shell_split(input)
	local words = {}
	local word = {}
	local in_single = false
	local in_double = false
	local escape = false

	for i = 1, #input do
		local c = input:sub(i, i)

		if escape then
			table.insert(word, c)
			escape = false
		elseif c == "\\" then
			if in_single then
				table.insert(word, c)
			else
				escape = true
			end
		elseif c == "'" then
			if in_single then
				in_single = false
			elseif not in_double then
				in_single = true
			else
				table.insert(word, c)
			end
		elseif c == '"' then
			if in_double then
				in_double = false
			elseif not in_single then
				in_double = true
			else
				table.insert(word, c)
			end
		elseif c:match("%s") and not in_single and not in_double then
			if #word > 0 then
				table.insert(words, table.concat(word))
				word = {}
			end
		else
			table.insert(word, c)
		end
	end

	if #word > 0 then
		table.insert(words, table.concat(word))
	end

	return words
end

return M
