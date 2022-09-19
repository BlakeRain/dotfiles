local trouble = require("trouble")
local utils = require("core.utils")

local M = {}
M.setup = function()
  trouble.setup({
    -- Show document diagnostics by default
    mode = "document_diagnostics"
  })

  utils.map("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
  utils.map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
  utils.map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
  utils.map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
  utils.map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")
  utils.map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>")
end

return M
