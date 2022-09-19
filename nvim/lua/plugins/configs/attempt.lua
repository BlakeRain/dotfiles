local utils = require("core.utils");
local attempt = require("attempt")
local telescope = require("telescope")

local M = {}

M.setup = function()
  attempt.setup({
    dir = vim.fn.expand("$HOME/cs/snip/attempt"),
    autosave = true,
    list_buffers = true
  })

  utils.map("n", "<Leader>an", attempt.new_select,
            { desc = "New attempt, select extension" })
  utils.map("n", "<Leader>ai", attempt.new_input_ext,
            { desc = "New attempt, enter extension" })
  utils.map("n", "<Leader>ar", attempt.run, { desc = "Run attempt" })
  utils.map("n", "<Leader>ad", attempt.delete_buf,
            { desc = "Delete attempt from current buffer" })
  utils.map("n", "<Leader>ac", attempt.rename_buf,
            { desc = "Rename attempt from current buffer" })

  telescope.load_extension("attempt")
  utils.map("n", "<leader>al", "<cmd>Telescope attempt<cr>")
end

return M
