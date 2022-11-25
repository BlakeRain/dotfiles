local which_key = require("which-key")

local M = {}
M.setup = function()
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

  -- Register our keymaps
  which_key.register({
    ["<leader><space>"] = { "Toggle folded region" },
    ["<leader>c"] = { name = "+Code" },
    ["<leader>cw"] = { name = "+LSP Workspace" },
    ["<leader>g"] = { name = "+Git" },
    ["<leader>q"] = { name = "+Quickfix" },
    ["<leader>w"] = { name = "+Windows" }
  })
end

return M
