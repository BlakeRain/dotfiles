-- Add Rust stuff to NeoVim
-- https://github.com/mrcjkb/rustaceanvim

local M = {
  "mrcjkb/rustaceanvim",
  version = "^3",
  ft = { "rust" }
}

vim.g.rustaceanvim = function()
  local lsp = require("plugins.lsp")

  return {
    server = {
      on_attach = lsp.on_attach,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          check = {
            enable = true,
            command = "clippy",
            features = "all"
          },
          procMacro = {
            enable = true
          }
        }
      }
    }
  }
end

return M
