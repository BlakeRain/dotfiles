local which_key = require("which-key")

local M = {}
M.setup = function()
  which_key.setup({
    plugins = {
      presets = {
        spelling = true, -- Display spelling suggestions (actually done by Telescope now)
        operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true -- bindings for prefixed with g
      }
    }
  })

  -- which_key.register({
  --   k = "Clear search highlight",
  --   t = "Open floating terminal",
  --   v = "Toggle CHADtree",
  --   s = "Open symbols outline",
  --   f = {
  --     name = "Telescope prefix",
  --     f = "Find files with Telescope",
  --     g = "Live grep with Telescope",
  --     b = "Buffer search with Telescope",
  --     h = "Search help with Telescope",
  --     c = "Search cheatsheets",
  --   },
  --   g = {
  --     name = "Neogit",
  --     g = "Open Neogit"
  --   },
  --   b = {
  --     b = "Order by buffer number",
  --     d = "Order by directory",
  --     l = "Order by language",
  --     w = "Order by window number",
  --   },
  --   j = "Hop to word",
  --   l = "Hop to line"
  -- }, { prefix = "<leader>" })
end

return M
