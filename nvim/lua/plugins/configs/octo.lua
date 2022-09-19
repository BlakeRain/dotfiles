local utils = require("core.utils")
local octo = require("octo")

local M = {}

M.setup = function()
  octo.setup({
    default_remote = { "upstream", "origin" },
    github_hostname = "github.com"
  })

  utils.map("n", "<leader>oil", "<cmd>Octo issue list<CR>")
  utils.map("n", "<leader>oic", "<cmd>Octo issue create<CR>")
  utils.map("n", "<leader>opl", "<cmd>Octo pr list<CR>")
  utils.map("n", "<leader>ops", "<cmd>Octo pr search<CR>")
  utils.map("n", "<leader>orl", "<cmd>Octo repo list<CR>")
  utils.map("n", "<leader>ogl", "<cmd>Octo gist list<CR>")

  -- List issues in the compliance tasks repository
  utils.map("n", "<leader>oti",
            "<cmd>Octo issue list NeoTechnologiesLtd/compliance-tasks<CR>")
end

return M
