local treesitter = require("nvim-treesitter.configs")

local M = {}
M.setup = function()
  treesitter.setup({
    ensure_installed = "all",
    sync_install = false,
    ignore_install = { "phpdoc" },
    highlight = {
      enable = true,
      disable = { "org" },
      additional_vim_regex_highlighting = { "org" }
    },
    autotag = { enable = true },
    indent = { enable = true, disable = { "rust", "yaml", "solidity" } },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump ahead to text object
        keymaps = {
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aC"] = "@call.outer",
          ["iC"] = "@call.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ip"] = "@parameter.inner",
          ["as"] = "@statement.outer",
          ["ap"] = "@parameter.outer"
        }
      },
      swap = {
        enable = true,
        swap_next = { ["<leader>a"] = "@parameter.inner" },
        swap_previous = { ["<leader>A"] = "@parameter.inner" }
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer"
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer"
        }
      }
    }
  })
end

return M
