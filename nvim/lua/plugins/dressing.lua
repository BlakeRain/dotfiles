-- Display dressings for neovim
-- https://github.com/stevearc/dressing.nvim
local M = {
  "stevearc/dressing.nvim",
  lazy = true
}

function M.init()
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(...)
    require("lazy").load({ plugins = { "dressing.nvim" } })
    return vim.ui.select(...)
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.input = function(...)
    require("lazy").load({ plugins = { "dressing.nvim" } })
    return vim.ui.input(...)
  end
end

return M
