local M = {}

---@return string git_root
function M.git_root()
	if vim.b.git_root then return vim.b.git_root end
	local git_root_cmd = vim.system({ "git", "-C", vim.fn.getcwd(), "rev-parse", "--show-toplevel" }):wait()
	vim.b.git_root = (git_root_cmd.code == 0) and vim.fn.fnamemodify(vim.trim(git_root_cmd.stdout), ":t") or
	                 git_root_cmd.stderr:sub(1, 20)
	return vim.b.git_root
end

---@return string git_head
function M.git_head()
	if vim.b.git_head then return vim.b.git_head end
	local git_head_cmd = vim.system({ "git", "-C", vim.fn.getcwd(), "rev-parse", "--abbrev-ref", "HEAD" }):wait()
	vim.b.git_head = (git_head_cmd.code == 0) and vim.trim(git_head_cmd.stdout) or git_head_cmd.stderr:sub(1, 20)
	return vim.b.git_head
end

return M
