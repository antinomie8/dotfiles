local path = vim.fn.stdpath("data") .. "/site/pack/nvim-treesitter/.tsqueryrc.json"
local content = require("utils").loadfile(path)
if not content then return {} end

return { init_options = vim.json.decode(content) }
