-- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
-- https://github.com/jose-elias-alvarez/null-ls.nvim

local M = {
  "jose-elias-alvarez/null-ls.nvim"
}


function M.setup()
  local null_ls = require("null-ls")
  local lsp = require("plugins.lsp")
  local utils = require("core.utils.rust")

  null_ls.setup({
    -- debug = true,
    on_attach = lsp.on_attach,
    sources = {
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.rustfmt.with({
        extra_args = function(params)
          local edition = utils.get_rust_edition(params.root)

          -- Default edition when we cannot find 'Cargo.toml' (or an 'edition' line therein)
          edition = edition or "2021"

          return {
            "--edition=" .. edition,
          }
        end
      })
    }
  })
end

function M.has_formatter(filetype)
  local sources = require("null-ls.sources")
  local available = sources.get_available(filetype, "NULL_LS_FORMATTING")
  return #available > 0
end

return M
