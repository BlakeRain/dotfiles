-- Standalone UI for nvim-lsp progress
-- https://github.com/j-hui/fidget.nvim
local M = {
  'j-hui/fidget.nvim',
  event = "VeryLazy"
}

function M.config()
  require('fidget').setup({})
end

return M
