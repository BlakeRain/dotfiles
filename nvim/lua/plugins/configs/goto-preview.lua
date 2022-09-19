local goto_preview = require("goto-preview")
local utils = require("core.utils")

local M = {}
M.setup = function()
  goto_preview.setup({})

  utils.map("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>")
  utils.map("n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
  utils.map("n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>")
  utils.map("n", "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>")
end

return M
