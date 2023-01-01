-- Color scheme: tokyonight
-- https://github.com/folke/tokyonight.nvim

local M = {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000
}

function M.config()
  -- vim.o.background = "dark"
  local tokyonight = require("tokyonight")
  tokyonight.setup({
    style = "night",
    transparent = true,
  })

  tokyonight.load()

  -- Add an override for the window borders
  vim.cmd [[highlight WinSeparator guifg=#313349 guibg=#1a1b27]]

  -- Add an override to make comments a little easier to perceive
  vim.cmd [[highlight Comment guifg=#7079a5]]
end

return M
