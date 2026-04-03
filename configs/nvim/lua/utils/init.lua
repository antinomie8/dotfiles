local M = {}

---@param path string path to file to load
---@return string? content file contents
function M.loadfile(path)
	local fd = vim.uv.fs_open(path, "r", 438)
	if not fd then return end
	local stat = vim.uv.fs_fstat(fd)
	local content = stat and vim.uv.fs_read(fd, stat.size, 0) or nil
	vim.uv.fs_close(fd)
	return content
end

return M
