-- https://github.com/shellRaining/hlchunk.nvim
return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local mocha = require("catppuccin.palettes").get_palette "mocha"
    require("hlchunk").setup({
      chunk = {
        enable = true,
        style = {
          { fg = mocha.overlay2 },
          { fg = mocha.red }
        },
      },
      indent = {
        enable = true
      },
    })
  end
}
