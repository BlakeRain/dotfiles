-- WARN: This is not enabled yet, as I'm having some problems with getting things running
local neorg = require('neorg');

local M = {}

M.setup = function()
  neorg.setup({
    load = {
      -- Load all modules (for full Neorg experience)
      ["core.defaults"] = {},
      ["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
      ["core.norg.concealer"] = { config = {} },
      ["core.norg.dirman"] = {
        config = {
          workspaces = {
            work = "~/cs/neorg/work",
            personal = "~/cs/neorg/personal"
          }
        }
      }
    }
  })
end

return M
