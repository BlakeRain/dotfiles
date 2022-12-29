-- Pretty list of LSP diagnostic
-- https://github.com/folke/trouble.nvim

local M = {
  'folke/trouble.nvim',
  cmd = "TroubleToggle",
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble Window" },
    { "<leader>xw", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", desc = "Toggle Workspace Diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", desc = "Toggle Document Diagnostics" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Toggle loclist Window" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Toggle quickfix Window" },
    { "gR", "TroubleToggle lsp_references<cr>", desc = "Toggle Reference Window" },
  },
}

function M.config()
  local trouble = require("trouble")

  trouble.setup({
    -- Show document diagnostics by default
    mode = "document_diagnostics"
  })
end

return M
