-- Add Rust stuff to NeoVim
-- https://github.com/mrcjkb/rustaceanvim

local M = {
  "mrcjkb/rustaceanvim",
  version = "^6",
  lazy = false,
}

vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      require("plugins.lsp").on_attach(client, bufnr)
    end,
  }
}

return M
