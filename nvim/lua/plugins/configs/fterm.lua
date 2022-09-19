--
-- WARNING: Note that I use ToggleTerm now
--
local fterm = require("FTerm")
local utils = require("core.utils")

local M = {}
M.setup = function()
  fterm.setup({ border = "double", dimensions = { width = 0.9, height = 0.9 } })

  utils.map("n", "<leader>t", "<CMD>lua require('FTerm').toggle()<CR>",
            { silent = true })
  utils.map("t", "<C-t>", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>",
            { silent = true })
end

return M
