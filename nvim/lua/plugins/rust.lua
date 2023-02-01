-- Enable more of the rust-analyzer features (e.g. inlay hints)
-- https://github.com/simrat39/rust-tools.nvim
local rust_tools = {
  "simrat39/rust-tools.nvim",
  ft = "rust"
}

local rust_group = vim.api.nvim_create_augroup("RustSettings",
  { clear = true })

function rust_tools.config()
  local tools = require("rust-tools")
  local lsp = require("plugins.lsp")

  vim.cmd([[highlight InlayHint ctermfg=14 gui=italic guifg=#333a65]])

  -- Setup the rust language server
  tools.setup({
    tools = {
      -- hover_with_actions = true,
      inlay_hints = {
        auto = false,
        parameter_hints_prefix = "←─ ",
        other_hints_prefix = "─→ ",
        highlight = "InlayHint"
      }
    },

    server = {
      on_attach = lsp.on_attach,
      flags = { debounce_text_changes = 250 },
      capabilities = lsp.get_capabilities(),
      settings = {
        ["rust-analyzer"] = { checkOnSave = { command = "clippy" } }
      }
    }
  })

  -- Tell rust that we want to override the "recommended" style
  vim.g.rust_recommended_style = 0

  -- Create an augroup for Rust that sets the textwidth to 120 (rather than the mandated 100)
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

  -- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  --   pattern = { "*.rs" },
  --   group = rust_group,
  --   callback = function(info)
  --     -- vim.lsp.buf.formatting_sync({ bufnr = info.buf })
  --     vim.lsp.buf.format({ bufnr = info.buf, async = false })
  --   end
  -- })
end

-- A neovim plugin that helps managing crates.io dependencies.
-- https://github.com/Saecki/crates.nvim
local crates = {
  "saecki/crates.nvim",
  tag = "v0.3.0",
  event = "VeryLazy"
}

function crates.config()
  require("crates").setup({
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = { "*.toml" },
    group = rust_group,
    callback = function(info)
      local function buf_set_keymap(mode, lhs, func, desc)
        vim.api.nvim_buf_set_keymap(info.buf, mode, lhs, "<cmd>lua require('crates')." .. func .. "()<cr>",
          { noremap = true, silent = true, desc = desc })
      end

      buf_set_keymap("n", "K", "show_documentation")
      buf_set_keymap("n", "<leader>Cv", "show_versions_popup", "Show versions")
      buf_set_keymap("n", "<leader>Cf", "show_features_popup", "Show features")
      buf_set_keymap("n", "<leader>Cd", "show_dependencies_popup", "Show dependencies")

      buf_set_keymap("n", "<leader>Cu", "update_crate", "Update crate")
      buf_set_keymap("v", "<leader>Cu", "update_crates", "Update selected crates")
      buf_set_keymap("n", "<leader>Ca", "update_all_crates", "Update all crates")
      buf_set_keymap("n", "<leader>CU", "upgrade_crate", "Upgrade crate")
      buf_set_keymap("v", "<leader>CU", "upgrade_crates", "Upgrade selected crates")
      buf_set_keymap("n", "<leader>CA", "upgrade_all_crates", "Upgrade all crates")

      buf_set_keymap("n", "<leader>CH", "open_homepage", "Open crate homepage")
      buf_set_keymap("n", "<leader>CR", "open_repository", "Open crate repository")
      buf_set_keymap("n", "<leader>CD", "open_documentation", "Open crate documentation")
      buf_set_keymap("n", "<leader>CC", "open_crates_io", "Open crates.io")
    end
  })
end

return {
  rust_tools,
  crates
}
