local utils = require("core.utils");
local notify = require("notify");

local M = {}
M.setup = function()
  notify.setup({})
  utils.map("n", "<leader>fn", "<cmd>:Notifications<cr>",
            { desc = "Show Notifications" })
end

return M
