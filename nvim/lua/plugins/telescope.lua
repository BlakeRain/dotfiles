-- Telescope for searching for anything
-- https://github.com/nvim-telescope/telescope.nvim

local function spell_check()
  local builtin = require("telescope.builtin")
  local themes = require("telescope.themes")
  builtin.spell_suggest(themes.get_cursor({
    prompt_title = "",
    layout_config = { width = 0.25, height = 0.25 }
  }))
end

local M = {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },

  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim", build = "make"
    },
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-cheat.nvim",
    "benfowler/telescope-luasnip.nvim",
    "sudormrfbin/cheatsheet.nvim"
  },

  keys = {

    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Show Git Commits" },
    { "<leader>gb", "<cmd>Telescope git_bcommits<cr>", desc = "Show Git Buffer Commits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Show Git Status" },

    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Buffer" },
    { "<leader>fd", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP Document Symbols" },
    { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Filter Diagnostics" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Filter Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fG", "<cmd>Telescope grep_string<cr>", desc = "Live Grep String" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>fHc", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Filter Jumplist" },
    { "<leader>fl", "<cmd>Telescope luasnip<cr>", desc = "Filter Luasnip Snippets" },
    { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Filter Marks" },
    { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
    { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Show Notifications" },
    { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Filter Registers" },
    { "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Telescope Resume" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "LSP Workspace Symbols" },
    { "<leader>fs", spell_check, { desc = "Spelling Suggestions" }, desc = "Spelling Suggestions" },
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Telescope Todos" },
    { "<leader>fT", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtins" },

    { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definitions" },
    { "gr", "<cmd>Telescope lsp_references<cr>", desc = "Goto References" },
  },
}

function M.config()
  local telescope = require("telescope")

  telescope.setup({
    defaults = {
      winblend = 10,
      mappings = {
        i = { ["<C-j>"] = "select_default", ["<C-h>"] = "which_key" },
        n = { ["<C-j>"] = "select_default" },
      },
      file_ignore_patterns = {
        "node_modules",
        "__pycache__",
        "package-lock.json",
        "yarn.lock",
        "Cargo.lock"
      }
    },
    pickers = {
      help_tags = { layout_config = { preview_width = 0.7 } },
      live_grep = {
        layout_strategy = "vertical",
        layout_config = {
          width = 0.9,
          height = 0.9,
          preview_height = 0.6,
          preview_cutoff = 0
        }
      }
    },
    extensions = {
    }
  })

  telescope.load_extension("notify")
  telescope.load_extension("attempt")
end

return M
