local octo = require("octo")

local M = {}

M.setup = function()
  octo.setup({
    default_remote = { "upstream", "origin" },
    github_hostname = "github.com"
  })
end

return M
