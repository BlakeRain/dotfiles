local utils = require("core.utils")
local octo = require("octo")
local wk = require("which-key")

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

  wk.register({
    ["<leader>o"] = { name = "+Octocat" },
    ["<leader>oi"] = { name = "+Ocotocat issues" },
    ["<leader>op"] = { name = "+Ocotocat PRs" },
    ["<leader>or"] = { name = "+Ocotocat repos" },
    ["<leader>og"] = { name = "+Ocotocat gists" },
    ["<leader>ot"] = { name = "+Ocotocat misc." }
  })

  -- For some reason, Octo is not picking up my color scheme, so let's override some stuff here
  vim.cmd([[
    highlight OctoEditable guifg=#c0caf5 guibg=#16161e
    highlight OctoGreenFloat guibg=#16161e
    highlight OctoRedFloat guibg=#16161e
    highlight OctoPurpleFloat guibg=#16161e
    highlight OctoYellowFloat guibg=#16161e
    highlight OctoBlueFloat guibg=#16161e
    highlight OctoGreyFloat guibg=#16161e
  ]])
end

return M
