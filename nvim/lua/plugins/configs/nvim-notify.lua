local utils = require("core.utils");
local notify = require("notify");

local M = {}
M.setup = function()
  notify.setup({})
  utils.map("n", "<leader>fn", "<cmd>:Telescope notify<cr>",
            { desc = "Show Notifications" })
  require("telescope").load_extension("notify")
end

return M
