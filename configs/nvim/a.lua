local str = string.gsub("-: 29.48: no matching function 'perpendicular(line, point)'", "%-: (%d+)%.", function(num)
	vim.notify(vim.inspect("hi"))
	local new_num = tonumber(num) - 16
	return string.format("-: %d.1:", new_num)
end)

vim.notify(vim.inspect(str))
