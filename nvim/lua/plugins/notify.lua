-- Notification manager for NeoVim
-- https://github.com/rcarriga/nvim-notify
--
-- This is a nice notification manager. Hopefully more plugins will start to use it.
local M = {
  "rcarriga/nvim-notify",
  lazy = false
}

function M.config()
  require("notify").setup({})
end

return M
