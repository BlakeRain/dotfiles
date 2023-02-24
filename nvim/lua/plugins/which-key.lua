-- Which-key functionality to help me remember what keys are configured
-- https://github.com/folke/which-key.nvim

local M = {
  "folke/which-key.nvim",
  lazy = false
}

function M.config()
  local which_key = require("which-key")
  which_key.setup({
    plugins = {
      presets = {
        spelling = true,
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true
      }
    }
  })

  which_key.register({
    ["<leader><space>"] = { "Toggle folded region" },
    ["<leader>a"] = { name = "+Attempt" },
    ["<leader>b"] = { name = "+Buffers" },
    ["<leader>c"] = { name = "+Code" },
    ["<leader>C"] = { name = "+Cargo" },
    ["<leader>cR"] = { name = "+Rust" },
    ["<leader>co"] = { name = "+Code & OpenAI" },
    ["<leader>cw"] = { name = "+LSP workspace" },
    ["<leader>f"] = { name = "+Telescope" },
    ["<leader>fc"] = { name = "+Telescope commits" },
    ["<leader>fH"] = { name = "+Telescope cheats" },
    ["<leader>g"] = { name = "+Git (& others)" },
    ["<leader>gh"] = { name = "+Git hunks" },
    ["<leader>gp"] = { name = "+Goto preview" },
    ["<leader>n"] = { name = "+Noice" },
    ["<leader>q"] = { name = "+Quickfix" },
    ["<leader>w"] = { name = "+Windows" },
    ["<leader>x"] = { name = "+Trouble" },
  })
end

return M
