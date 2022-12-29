-- Colorizer: highlights colors using their color
-- https://github.com/NvChad/nvim-colorizer.lua
--
-- This plugin will change the background of a color (such as CSS hex) to match the actual color defined.
--
-- This is currently restricted to CSS-like filetypes.

local M = {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre"
}

function M.config()
  require("colorizer").setup({
    filetypes = { "html", "css", "scss", "sass", "less" },
    user_default_options = {
      rgb_fn = true,
      hsl_fn = true,
      sass = { enable = true, parsers = { css = true } },
      mode = "background"
    }
  })
end

return M
