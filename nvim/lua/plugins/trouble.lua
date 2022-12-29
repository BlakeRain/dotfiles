-- Pretty list of LSP diagnostic
-- https://github.com/folke/trouble.nvim

local M = {
  'folke/trouble.nvim',
  cmd = "TroubleToggle",
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble window" },
    { "<leader>xw", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", desc = "Toggle workspace diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", desc = "Toggle document diagnostics" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Toggle loclist window" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Toggle quickfix window" },
    { "gR", "TroubleToggle lsp_references<cr>", desc = "Toggle reference window" },
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
