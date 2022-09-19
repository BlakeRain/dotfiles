local neogen = require("neogen")
local utils = require("core.utils")

local M = {}
M.setup = function()
  neogen.setup({
  })

  utils.map("n", "<Leader>nn", ":lua require('neogen').generate()<CR>")
  utils.map("n", "<Leader>nf", ":lua require('neogen').generate({ type = 'func' })<CR>")
  utils.map("n", "<Leader>nc", ":lua require('neogen').generate({ type = 'class' })<CR>")
  utils.map("n", "<Leader>nt", ":lua require('neogen').generate({ type = 'type' })<CR>")
  utils.map("n", "<Leader>nF", ":lua require('neogen').generate({ type = 'file' })<CR>")
end

return M
