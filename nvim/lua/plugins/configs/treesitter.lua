local treesitter = require("nvim-treesitter.configs")
local orgmode = require("orgmode")

local M = {}
M.setup = function()
  orgmode.setup_ts_grammar()

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
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["as"] = "@statement.outer",
          ["aC"] = "@call.outer",
          ["iC"] = "@call.inner",
          ["ap"] = "@parameter.outer",
          ["ip"] = "@parameter.inner"
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
