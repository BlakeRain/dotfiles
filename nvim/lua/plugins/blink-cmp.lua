-- https://github.com/Saghen/blink.cmp
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "v0.*",
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.*" }
  },
  opts = {
    keymap = {
      preset = "default",
      -- ["<C-j>"] = { "select_and_accept" },  Use C-Y to accept, see :help ins-completion
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
      -- providers = {
      --   luasnip = {
      --     opts = {
      --       use_show_condition = false
      --     }
      --   }
      -- }
    },
    snippets = {
      preset = "luasnip",
      -- expand = function(snippet)
      --   require("luasnip").lsp_expand(snippet)
      -- end,
      -- active = function(filter)
      --   if filter and filter.direction then
      --     return require("luasnip").jumpable(filter.direction)
      --   end
      --
      --   return require("luasnip").in_snippet()
      -- end,
      -- jump = function(direction)
      --   require("luasnip").jump(direction)
      -- end
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
