local dressing = require("dressing");

local M = {}
M.setup = function()
  dressing.setup({
    input = {
      winblend = 10
    }
  })
end

return M
