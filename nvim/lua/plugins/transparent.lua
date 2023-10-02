-- Remove all background colors to make neovim transparent.
-- https://github.com/xiyaowong/transparent.nvim

local M = {
  "xiyaowong/transparent.nvim",
  lazy = false
}

function M.config()
  local transparent = require("transparent")

  transparent.setup({
    extra_groups = {},
    exclude_groups = {}
  })

  -- transparent.clear_prefix("lualine")
  transparent.clear_prefix("NeoTree")
end

return M
