-- Remove all background colors to make neovim transparent.
-- https://github.com/xiyaowong/transparent.nvim

local M = {
  "xiyaowong/transparent.nvim",
  lazy = false
}

function M.config()
  local transparent = require("transparent")

  transparent.setup({
    groups = {
      'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
      'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
      'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
      'SignColumn', 'StatusLine', 'StatusLineNC',
      'EndOfBuffer',
    },
    extra_groups = {},
    exclude_groups = {}
  })

  -- transparent.clear_prefix("lualine")
  -- transparent.clear_prefix("NeoTree")
  transparent.clear_prefix("MiniFiles")
end

return M
