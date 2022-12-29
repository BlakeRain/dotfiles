-- Diffview support, used by neogit
-- https://github.com/sindrets/diffview.nvim

local M = {
  'sindrets/diffview.nvim',
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = true
}

return M
