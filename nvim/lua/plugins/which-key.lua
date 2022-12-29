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
    ["<leader>b"] = { name = "+Buffers" },
    ["<leader>c"] = { name = "+Code" },
    ["<leader>C"] = { name = "+Cargo" },
    ["<leader>co"] = { name = "+Code & OpenAI" },
    ["<leader>cw"] = { name = "+LSP Workspace" },
    ["<leader>f"] = { name = "+Telescope" },
    ["<leader>fc"] = { name = "+Telescope Commits" },
    ["<leader>fH"] = { name = "+Telescope Cheats" },
    ["<leader>g"] = { name = "+Git" },
    ["<leader>gp"] = { name = "+Goto Preview" },
    ["<leader>q"] = { name = "+Quickfix" },
    ["<leader>w"] = { name = "+Windows" },
    ["<leader>a"] = { name = "+Attempt" },
  })
end

return M
