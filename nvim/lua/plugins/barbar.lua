-- Provide a list of buffers in a 'tab-bar' at the top of the window without changing how vim tabs work
-- https://github.com/romgrk/barbar.nvim

local M = {
  "romgrk/barbar.nvim",
  event = "BufAdd",

  keys = {
    -- Move to previous or next buffer
    { "<A-,>",      "<cmd>BufferPrevious<cr>" },
    { "<A-.>",      "<cmd>BufferNext<cr>" },

    -- Re-order current buffer
    { "<A-<>",      "<cmd>BufferMovePrevious<cr>" },
    { "<A->>",      "<cmd>BufferMoveNext<cr>" },

    -- Goto buffer in position
    { "<A-1>",      "<cmd>BufferGoto 1<cr>" },

    -- Pin or unpin a buffer
    { "<A-p>",      "<cmd>BufferPin<cr>" },

    -- Close buffer
    { "<A-c>",      "<cmd>BufferClose<cr>" },

    -- Magic buffer-picking mode
    { "<C-s>",      "<cmd>BufferPick<cr>" },

    { "<leader>bb", "<cmd>BufferPick<cr>",                       desc = "Pick buffer" },
    { "<leader>bc", "<cmd>BufferClose<cr>",                      desc = "Close buffer" },
    { "<leader>bC", "<cmd>BufferClose!<cr>",                     desc = "Close buffer (force)" },
    { "<leader>bx", "<cmd>BufferCloseAllButCurrentOrPinned<cr>", desc = "Close all buffers" },

    -- Move to previous or next buffer
    { "<leader>bn", "<cmd>BufferNext<cr>",                       desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferPrevious<cr>",                   desc = "Previous buffer" },

    -- Pin or unpin a buffer
    { "<leader>bP", "<cmd>BufferPin<cr>",                        desc = "Pin or unpin buffer" },
  },

  opts = {
    tabpages = true
  }
}

for i = 1, 9 do
  table.insert(M.keys, { ("<A-%i>"):format(i), ("<cmd>BufferGoto %i<cr>"):format(i) })
end

return M
