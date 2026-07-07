local tex = require("utils.snippets.tex_utils")
local abbreviations = require("snippets.abbreviations")

return abbreviations.setup(tex.in_text * tex.in_document * tex.not_in_cmd)
