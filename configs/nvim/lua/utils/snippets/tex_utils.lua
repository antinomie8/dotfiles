local make_cond = require("utils.snippets.luasnip").make_cond
local trigger_not_preceded_by = require("luasnip.extras.expand_conditions").trigger_not_preceded_by

local tex_utils = {}

tex_utils.in_math = make_cond(function()
	return require("utils.treesitter").has_ancestor(
		vim.treesitter.get_node(),
		{ "inline_formula", "displayed_equation", "math_environment" },
		{ "text_mode" }
	)
end)
tex_utils.in_text = make_cond(function()
	return -tex_utils.in_math
end)

local function in_environment(name)
	local node = vim.treesitter.get_node()
	while node do
		if node:type() == "generic_environment" then
			local word_node = node:named_child(0):named_child(0):named_child(0):named_child(0)
			local text = vim.treesitter.get_node_text(word_node, 0)
			if text == name or text == name .. "*" then
				return true
			end
		end
		node = node:parent()
	end
	return false
end
tex_utils.in_env = make_cond(function(name)
	return in_environment(name)
end)
tex_utils.in_document = make_cond(function()
	return in_environment("document") or vim.env.OLY
end)
tex_utils.in_preamble = make_cond(function()
	return not in_environment("document")
end)
tex_utils.in_equation = make_cond(function()
	return in_environment("equation")
end)
tex_utils.in_itemize = make_cond(function()
	return in_environment("itemize")
end)
tex_utils.in_tikz = make_cond(function()
	return in_environment("tikzpicture")
end)

tex_utils.not_in_cmd = trigger_not_preceded_by("[%a\\]")

return tex_utils
