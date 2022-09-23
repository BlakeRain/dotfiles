local map = require("core.utils").map
local mini_starter = require("mini.starter")
local mini_cursorword = require("mini.cursorword")
local mini_align = require("mini.align")
local mini_ai = require("mini.ai")
local mini_indentscope = require("mini.indentscope")
local mini_misc = require("mini.misc")

local M = {}
M.setup = function()
  mini_starter.setup({})

  mini_cursorword.setup({
    -- Delay (in ms) between when the cursor moved and when highlighting appears
    delay = 250
  })

  mini_align.setup({ mappings = { start = '', start_with_preview = "gA" } })

  mini_ai.setup({ custom_text_objects = nil })

  mini_indentscope.setup({})

  map("n", "<leader>bz", function() mini_misc.zoom(0, {}) end,
      { desc = "Zoom into buffer" })
end

return M
