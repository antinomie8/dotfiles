local treesitter = {}

---@param node TSNode?
---@param ancestor_type string
---@param exclude table<string> ancestor nodes to exclude
---@return boolean? has_ancestor wether node has an ancestor of type ancestor_type
function treesitter.has_ancestor(node, ancestor_type, exclude)
	while node do
		if ancestor_type == node:type() then
			return true
		elseif vim.tbl_contains(exclude, node:type()) then
			return false
		end
		node = node:parent()
	end
	return false
end

return treesitter
