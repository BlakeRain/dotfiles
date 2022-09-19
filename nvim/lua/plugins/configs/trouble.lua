local trouble = require("trouble")
local utils = require("core.utils")
local wk = require("which-key")

local M = {}
M.setup = function()
  trouble.setup({
    -- Show document diagnostics by default
    mode = "document_diagnostics"
  })

  utils.map("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
            { desc = "Toggle Trouble Window" })
  utils.map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
            { desc = "Toggle Workspace Diagnostics" })
  utils.map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
            { desc = "Toggle Document Diagnostics" })
  utils.map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
            { desc = "Toggle quickfix Window" })
  utils.map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
            { desc = "Toggle loclist Window" })
  utils.map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
            { desc = "Toggle References Window" })

  wk.register({ ["<leader>x"] = { name = "+Trouble" } })
end

return M
