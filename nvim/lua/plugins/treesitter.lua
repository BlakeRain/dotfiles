-- Treesitter for better syntax highlighting
-- https://github.com/nvim-treesitter/nvim-treesitter

local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",

      -- Treesitter Playground
      "nvim-treesitter/playground",

      -- Show current context
      -- https://github.com/nvim-treesitter/nvim-treesitter-context
      "nvim-treesitter/nvim-treesitter-context",

      -- Treesitter auto-taggery
      -- https://github.com/windwp/nvim-ts-autotag
      "windwp/nvim-ts-autotag",

      -- TreeSJ: split or join blocks of code
      -- https://github.com/Wansmer/treesj
      "Wansmer/treesj"
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- ensure_installed = "all",
        ensure_installed = {
          "bash",
          "c",
          "cmake",
          "comment",
          "cpp",
          "css",
          "cuda",
          "diff",
          "dockerfile",
          "dot",
          "fish",
          "gitcommit",
          "gitignore",
          "glsl",
          "go",
          "gomod",
          "haskell",
          "html",
          "java",
          "javascript",
          "json",
          "jsonc",
          "latex",
          "lua",
          "make",
          "python",
          "regex",
          "rust",
          "scss",
          "sql",
          "toml",
          "tsx",
          "typescript",
          "vimdoc",
          "yaml"
        },
        sync_install = true,
        -- ignore_install = { "phpdoc", "d" },
        highlight = {
          enable = true,
          disable = { "org" },
          additional_vim_regex_highlighting = { "org" }
        },
        autotag = { enable = true },
        indent = { enable = true, disable = { "rust", "yaml", "solidity", "python" } },
        incremental_selection = {
          -- Disable while https://github.com/nvim-treesitter/nvim-treesitter/issues/4000
          enable = false,
          keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<cr>",
            scope_incremental = "<c-s>",
            node_decremental = "<c-backspace>"
          }
        },
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

      require("treesitter-context").setup({ enabled = true })
      require("treesj").setup({ use_default_keymaps = false })
      vim.keymap.set("n", "<leader>m", "<cmd>TSJToggle<cr>", { desc = "Toggle split" })
    end
  }
}

return M
