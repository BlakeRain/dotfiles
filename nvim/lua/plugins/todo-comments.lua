-- Todo comments
-- https://github.com/folke/todo-comments.nvim
local M = {
  'folke/todo-comments.nvim',
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = "BufReadPost",
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next todo comment",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous todo comment",
    },
  },
}

function M.config()
  require("todo-comments").setup({})
end

return M
