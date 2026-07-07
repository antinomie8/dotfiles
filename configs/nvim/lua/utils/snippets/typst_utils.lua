local helpers = require("utils.snippets.helpers")

local typst_utils = {}
typst_utils.in_math = helpers.in_node("math", { "string" })
typst_utils.in_text = -typst_utils.in_math

return typst_utils
