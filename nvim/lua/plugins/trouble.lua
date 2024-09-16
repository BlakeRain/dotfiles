-- Pretty list of LSP diagnostic
-- https://github.com/folke/trouble.nvim

-- local M = {
--   'folke/trouble.nvim',
--   cmd = "TroubleToggle",
--   keys = {
--     { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble window" },
--     { "<leader>xw", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", desc = "Toggle workspace diagnostics" },
--     { "<leader>xd", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", desc = "Toggle document diagnostics" },
--     { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Toggle loclist window" },
--     { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Toggle quickfix window" },
--     { "gR", "TroubleToggle lsp_references<cr>", desc = "Toggle reference window" },
--   },
-- }
--
-- function M.config()
--   local trouble = require("trouble")
--
--   trouble.setup({
--     -- Show document diagnostics by default
--     mode = "document_diagnostics",
--     action_keys = {
--       jump = { "<cr>", "<tab>", "<c-j>" }
--     }
--   })
-- end
--
-- return M

return {
  "folke/trouble.nvim",
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xb",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>xcs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>xcl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
}
