local comment = require("Comment")
local ft = require("Comment.ft")

local M = {}
M.setup = function()
  comment.setup()
  ft.set("groff", ".\\\"%s")
  ft.set("crontab", "#%s")
end

return M
