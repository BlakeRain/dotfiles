return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      integrations = {
        barbar = true,
        blink_cmp = true,
        gitsigns = true,
        lsp_trouble = true,
        mason = true,
        neogit = true,
        notify = true,
        octo = true,
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
          LspInlayHint = { fg = C.surface2, bg = C.base, style = { "italic" } },
          CursorLine = { bg = C.surface0 },
        }
      end
    })

    vim.cmd.colorscheme("catppuccin-mocha")
  end
}
