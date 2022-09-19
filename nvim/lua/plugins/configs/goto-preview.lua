local goto_preview = require("goto-preview")
local utils = require("core.utils")
local wk = require("which-key")

local M = {}
M.setup = function()
  goto_preview.setup({})

  utils.map("n", "gpd",
            "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
            { desc = "Preview Definition" })
  utils.map("n", "gpi",
            "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
            { desc = "Preview Implementation" })
  utils.map("n", "gpr",
            "<cmd>lua require('goto-preview').goto_preview_references()<CR>",
            { desc = "Preview References" })
  utils.map("n", "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>",
            { desc = "Close Preview Windows" })

  wk.register({ ["gp"] = { name = "+Preview" } })
end

return M
