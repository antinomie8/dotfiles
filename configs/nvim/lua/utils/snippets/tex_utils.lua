local make_cond = require("utils.snippets.luasnip").make_cond
local trigger_not_preceded_by = require("luasnip.extras.expand_conditions").trigger_not_preceded_by

local tex_utils = {}

tex_utils.in_math = make_cond(function()
	-- First check if we're in math mode at all
	if vim.fn["vimtex#syntax#in_mathzone"]() == 0 then
		return false
	end

	-- Get syntax stack at cursor
	local stack = vim.fn.synstack(vim.fn.line("."), vim.fn.col("."))
	for _, id in ipairs(stack) do
		local name = vim.fn.synIDattr(id, "name")
		-- If inside \text{} or similar, math highlighting group changes
		if name:match("texMathText") then
			return false
		end
	end

	return true
end)
tex_utils.in_text = make_cond(function()
	return vim.fn["vimtex#syntax#in_mathzone"]() ~= 1
end)
tex_utils.in_comment = make_cond(function()
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end)

local function in_environment(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
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
