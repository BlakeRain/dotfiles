-- Hop for moving around (like ace-jump)
-- https://github.com/phaazon/hop.nvim
local M = {
  "phaazon/hop.nvim",
  config = true,
  keys = {
    { 'f',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true })
      end },
    { 'F',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true })
      end },

    { 't',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true,
          hint_offset = -1 })
      end },
    { 'T',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true,
          hint_offset = 1 })
      end },

    { 'f',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true,
          inclusive_jump = true })
      end, mode = "o" },
    { 'F',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true,
          inclusive_jump = true })
      end, mode = "o" },

    { 't',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true,
          hint_offset = -1 })
      end, mode = "o" },
    { 'T',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true,
          hint_offset = 1 })
      end, mode = "o" },

    { 't',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true,
        })
      end, mode = "x" },
    { 'T',
      function()
        require("hop").hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true,
        })
      end, mode = "x" },

    { "<leader>j", function() require("hop").hint_words() end, desc = "Hop to Word" },
    { "<leader>l", function() require("hop").hint_lines() end, desc = "Hop to Line" },

    { "<leader>j", function() require("hop").hint_words() end, desc = "Hop to Word", mode = "v" },
    { "<leader>l", function() require("hop").hint_lines() end, desc = "Hop to Line", mode = "v" },
  }
}

return M
