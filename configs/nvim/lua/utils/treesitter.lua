local treesitter = {}

---@param node TSNode?
---@param ancestor_type string
---@return boolean? has_ancestor wether node has an ancestor of type ancestor_type
function treesitter.has_ancestor(node, ancestor_type)
	if not node then return end
	local parent = node:parent()
	while parent do
		if ancestor_type == parent:type() then
			return true
		end
		parent = parent:parent()
	end
	return false
end

return treesitter
