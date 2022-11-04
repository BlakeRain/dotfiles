local M = {}
M.setup = function()
  -- Enable tab to spaces conversion
  vim.g.neoformat_basic_format_retab = 1
  -- Enable trimming of trailing whitespace
  vim.g.neoformat_basic_format_trim = 1

  vim.g.neoformat_python_autopep8 = {
    exe = 'autopep8',
    args = { '--ignore', 'E402', '--max-line-length', '120' }
  }

  vim.g.neoformat_enabled_python = { 'autopep8' }

  vim.g.neoformat_enabled_javascript = { "prettier" }
  vim.g.neoformat_enabled_javascriptreact = { "prettier" }
  vim.g.neoformat_enabled_typescript = { "prettier" }
  vim.g.neoformat_enabled_typescriptreact = { "prettier" }

  vim.g.neoformat_enabled_toml = { "taplo" }

  vim.g.neoformat_lua_luaformat = {
    exe = "lua-format",
    args = {
      "--indent-width=2", "--tab-width=2", "--no-use-tab",
      "--continuation-indent-width=2", "--spaces-inside-table-braces"
    }
  }

  vim.g.neoformat_enabled_lua = { "luaformat" }

  vim.g.neoformat_enabled_rust = {}

  -- Format all sources when we save
  vim.cmd([[
  augroup fmt
    autocmd!
    autocmd BufWritePre * undojoin | Neoformat
  augroup END
  ]])

end

return M
