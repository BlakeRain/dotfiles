-- Commenting code
-- https://github.com/numToStr/Comment.nvim
local M = {
  'numToStr/Comment.nvim',
  event = { "BufReadPost", "BufNewFile" },
}

function M.config()
  local comment = require("Comment")
  local ft = require("Comment.ft")

  comment.setup()
  ft.set("groff", ".\\\"%s")
  ft.set("crontab", "#%s")
end

return M
