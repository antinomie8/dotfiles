local treesitter = {}

---@param node TSNode?
---@param ancestor_type string|string[]
---@param exclude table<string> ancestor nodes to exclude
---@return boolean has_ancestor wether node has an ancestor of type ancestor_type
function treesitter.has_ancestor(node, ancestor_type, exclude)
	if type(ancestor_type) == "string" then
		ancestor_type = { ancestor_type }
	end
	if exclude == nil then
		exclude = {}
	end

	while node do
		if vim.tbl_contains(ancestor_type, node:type()) then
			return true
		elseif vim.tbl_contains(exclude, node:type()) then
			return false
		end
		node = node:parent()
	end

	return false
end

return treesitter
