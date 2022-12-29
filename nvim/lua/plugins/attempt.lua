-- Attempt: Create temporary buffers and files
-- https://github.com/m-demare/attempt.nvim

local M = {
  "m-demare/attempt.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  keys = {
    { "<leader>al", "<cmd>Telescope attempt<cr>", desc = "List attempts" },
    { "<leader>an", function() require("attempt").new_select() end, desc = "New attempt, select extension" },
    { "<leader>ai", function() require("attempt").new_input_ext() end, desc = "New attempt, enter extension" },
    { "<leader>ar", function() require("attempt").run() end, desc = "Run attempt" },
    { "<leader>ad", function() require("attempt").delete_buf() end, desc = "Delete attempt from current buffer" },
    { "<leader>ac", function() require("attempt").rename_buf() end, desc = "Rename attempt from current buffer" },
  }
}

function M.config()
  local attempt = require("attempt")
  attempt.setup({
    dir = vim.fn.expand("$HOME/cs/snip/attempt"),
    autosave = true,
    list_buffers = true
  })
end

return M
