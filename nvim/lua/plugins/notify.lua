-- Notification manager for NeoVim
-- https://github.com/rcarriga/nvim-notify
--
-- This is a nice notification manager. Hopefully more plugins will start to use it.
local M = {
  "rcarriga/nvim-notify",
  lazy = false,
  opts = {
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
  },
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Delete all Notifications",
    },
  },
  init = function()
    -- when noice is not enabled, install notify on VeryLazy
    local utils = require("core.utils")
    if not utils.has("noice.nvim") then
      utils.on_very_lazy(function()
        vim.notify = require("notify")
      end)
    end
  end,
}


return M
