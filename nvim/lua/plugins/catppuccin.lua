return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      integrations = {
        barbar = true,
        cmp = true,
        gitsigns = true,
        hop = true,
        leap = true,
        lsp_trouble = true,
        mason = true,
        notify = true,
        treesitter = true,
        treesitter_context = true,
        ufo = true,
        which_key = true,

        mini = {
          enabled = true,
        },

        telescope = {
          enabled = true
        }
      },

      custom_highlights = function(C)
        return {
          NeoTreeNormal = { fg = C.text, bg = C.mantle },
          NeoTreeNormalNC = { fg = C.text, bg = C.mantle },
          LspInlayHint = { fg = C.surface2, bg = C.base, style = { "italic" } },
        }
      end
    })

    vim.cmd.colorscheme("catppuccin-mocha")
  end
}
