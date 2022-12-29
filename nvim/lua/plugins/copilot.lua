-- GitHub Copilot Integration
-- https://github.com/zbirenbaum/copilot.lua

local M = {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "zbirenbaum/copilot-cmp",
  },
  event = "VeryLazy"
}

function M.config()
  vim.defer_fn(function()
    require("copilot").setup()
    require("copilot_cmp").setup()
  end, 100)
end

return M
