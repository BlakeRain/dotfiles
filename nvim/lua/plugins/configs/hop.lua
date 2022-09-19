local hop = require("hop")
local utils = require("core.utils")

local M = {}
M.setup = function()
  hop.setup()

  utils.map('n', 'f',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>")
  utils.map('n', 'F',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>")
  utils.map('o', 'f',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<cr>")
  utils.map('o', 'F',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<cr>")
  utils.map('o', 't',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>")
  utils.map('o', 'T',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>")
  utils.map('x', 't',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>")
  utils.map('x', 'T',
            "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>")

  utils.map("n", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>",
            { desc = "Hop to Word" })
  utils.map("n", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>",
            { desc = "Hop to Line" })
  utils.map("v", "<leader>j", "<cmd>lua require'hop'.hint_words()<cr>",
            { desc = "Hop to Word" })
  utils.map("v", "<leader>l", "<cmd>lua require'hop'.hint_lines()<cr>",
            { desc = "Hop to Line" })
end

return M
