-- Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP
-- servers, linters, and formatters.
--
-- https://github.com/williamboman/mason.nvim

local M = {
  "williamboman/mason.nvim",
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  }
}

M.tools = {
  "prettierd",
  "stylua",
  "selene",
  "luacheck",
  "eslint_d",
  "shellcheck",
  "deno",
  "shfmt",
  "black",
  "isort",
  "flake8",
}

function M.check()
  local mr = require("mason-registry")
  for _, tool in ipairs(M.tools) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end

function M.config()
  require("mason").setup()
  M.check()
  require("mason-lspconfig").setup({
    automatic_installation = true,
  })
end

return M