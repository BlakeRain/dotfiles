-- https://github.com/Saghen/blink.cmp
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.*" }
  },
  opts = {
    keymap = {
      preset = "default",
    },
    appearance = {
      nerd_font_variant = "mono"
    },
    sources = {
      default = {
        "lsp",
        "snippets",
        "buffer"
      },
    },
    snippets = {
      preset = "luasnip",
    },
    completion = {
      menu = {
        draw = {
          columns = {
            { "kind_icon" },
            { "label",    "label_description", gap = 1 },
            { "kind" }
          }
        }
      },
      documentation = {
        auto_show = true,
        window = {
          border = "padded",
        }
      }
    },
    signature = {
      enabled = true
    }
  },
  config = function(_, opts)
    require("blink-cmp").setup(opts)

    -- Setup some custom highlight group stuff
    vim.cmd [[
      hi link BlinkCmpDoc Pmenu
      hi link BlinkCmpDocBorder Pmenu
      hi link BlinkCmpDocSeparator Pmenu
    ]]
  end
}
