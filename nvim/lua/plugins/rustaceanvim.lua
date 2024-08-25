-- Add Rust stuff to NeoVim
-- https://github.com/mrcjkb/rustaceanvim

local M = {
  "mrcjkb/rustaceanvim",
  version = "^4",
  lazy = false,
}

vim.g.rustaceanvim = function()
  local lsp = require("plugins.lsp")

  return {
    server = {
      on_attach = lsp.on_attach,
      settings = function(project_root)
        local ra = require('rustaceanvim.config.server')
        local settings = ra.load_rust_analyzer_settings(project_root, {
          settings_file_pattern = 'rust-analyzer.json'
        })

        return settings
      end

      -- settings = {
      --   ["rust-analyzer"] = {
      --     cargo = {
      --       allFeatures = true,
      --     },
      --     check = {
      --       enable = true,
      --       command = "clippy",
      --       features = "all"
      --     },
      --     procMacro = {
      --       enable = true
      --     },
      --     files = {
      --       excludeDirs = {
      --         ["**/node_modules"] = true,
      --       }
      --     }
      --   }
      -- }
    }
  }
end

return M
