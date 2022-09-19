local neogit = require("neogit")
local utils = require("core.utils")

local M = {}
M.setup = function()
  neogit.setup({
    integrations = {
      diffview = true
    }
  })

  function _G.neogit_current_buffer()
    neogit.open({ cwd = vim.fn.expand("%:p:h") })
  end

  utils.map("n", "<leader>gG", "<cmd>Neogit<cr>")
  utils.map("n", "<leader>gb", "<cmd>:lua neogit_current_buffer()<cr>")
end

return M
