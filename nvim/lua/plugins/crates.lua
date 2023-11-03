-- A neovim plugin that helps managing crates.io dependencies.
-- https://github.com/Saecki/crates.nvim
local M = {
  "saecki/crates.nvim",
  -- tag = "v0.4.0",
  event = "VeryLazy"
}

function M.config()
  require("crates").setup({
    max_parallel_requests = 20,
    src = {
      cmp = {
        enabled = true
      }
    }
  })

  vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    callback = function()
      require("cmp").setup.buffer({ sources = { { name = "crates" } } })
    end
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

return M
