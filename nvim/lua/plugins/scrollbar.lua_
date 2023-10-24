-- Extensible Neovim Scrollbar
-- https://github.com/petertriho/nvim-scrollbar

local M = {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
}

function M.config()
  local scrollbar = require("scrollbar")
  local colors = require("tokyonight.colors").setup()

  scrollbar.setup({
    handle = {
      color = colors.bg_highlight,
    },
    excluded_filetypes = {
      "prompt",
      "TelescopePrompt",
      "noice",
      "notify",
    },
    marks = {
      Search = { color = colors.orange },
      Error = { color = colors.error },
      Warn = { color = colors.warning },
      Info = { color = colors.info },
      Hint = { color = colors.hint },
      Misc = { color = colors.purple },
    },
    handlers = {
      gitsigns = true
    }
  })
end

return M
