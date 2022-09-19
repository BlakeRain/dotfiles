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
end

return M
