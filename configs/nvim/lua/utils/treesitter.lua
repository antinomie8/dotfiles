local treesitter = {}

function treesitter.has_ancestor(node, node_type)
	if not node then return end
	local parent = node:parent()
	while parent do
		if node_type == parent:type() then
			return true
		end
		parent = parent:parent()
	end
	return false
end

return treesitter
