local mini_starter = require("mini.starter")
local mini_cursorword = require("mini.cursorword")

local M = {}
M.setup = function()
  mini_starter.setup({})

  mini_cursorword.setup({
    -- Delay (in ms) between when the cursor moved and when highlighting appears
    delay = 250
  })
end

return M
