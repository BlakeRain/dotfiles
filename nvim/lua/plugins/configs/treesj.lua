local utils = require('core.utils')
local treesj = require("treesj")

local M = {}

M.setup = function()
  treesj.setup({ use_default_keymaps = false })
  utils.map("n", "<Leader>m", "<CMD>TSJToggle<CR>", { desc = "Toggle node" })
end

return M
