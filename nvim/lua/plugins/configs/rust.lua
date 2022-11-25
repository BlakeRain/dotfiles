local rust_tools = require("rust-tools")
local lsp_config = require("plugins.configs.nvim-lspconfig")

local M = {}
M.setup = function()
  vim.cmd([[highlight InlayHint ctermfg=14 gui=italic guifg=#333a65]])

  -- Setup the rust language server
  rust_tools.setup({
    tools = {
      autoSetHints = false,
      -- hover_with_actions = true,
      inlay_hints = {
        parameter_hints_prefix = "←─ ",
        other_hints_prefix = "─→ ",
        highlight = "InlayHint"
      }
    },

    server = {
      on_attach = lsp_config.on_attach,
      flags = { debounce_text_changes = 250 },
      capabilities = lsp_config.capabilities,
      settings = {
        ["rust_analyzer"] = { checkOnSave = { command = "cargo clippy" } }
      }
    }
  })

  -- Tell rust that we want to override the "recommended" style
  vim.g.rust_recommended_style = 0

  -- Create an augroup for Rust that sets the textwidth to 120 (rather than the mandated 100)
  local rust_group = vim.api.nvim_create_augroup("RustSettings",
                                                 { clear = true })
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.rs" },
    group = rust_group,
    callback = function(info)
      -- setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
      vim.api.nvim_buf_set_option(info.buf, "textwidth", 119)
      vim.api.nvim_buf_set_option(info.buf, "tabstop", 4)
      vim.api.nvim_buf_set_option(info.buf, "shiftwidth", 4)
      vim.api.nvim_buf_set_option(info.buf, "softtabstop", 4)
      vim.api.nvim_buf_set_option(info.buf, "expandtab", true)
    end
  })

  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.rs" },
    group = rust_group,
    callback = function(info)
      -- vim.lsp.buf.formatting_sync({ bufnr = info.buf })
      vim.lsp.buf.format({ bufnr = info.buf, async = false })
    end
  })
end

return M
