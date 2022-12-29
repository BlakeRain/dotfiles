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

    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Show git commits" },
    { "<leader>gb", "<cmd>Telescope git_bcommits<cr>", desc = "Show git buffer commits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Show git status" },

    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in buffer" },
    { "<leader>fd", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP document symbols" },
    { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Filter diagnostics" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Filter files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fG", "<cmd>Telescope grep_string<cr>", desc = "Live grep string" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fHc", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Filter jumplist" },
    { "<leader>fl", "<cmd>Telescope luasnip<cr>", desc = "Filter luasnip snippets" },
    { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Filter marks" },
    { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
    { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Show notifications" },
    { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Filter registers" },
    { "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Telescope resume" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "LSP workspace symbols" },
    { "<leader>fs", spell_check, { desc = "Spelling Suggestions" }, desc = "Spelling suggestions" },
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Telescope todos" },
    { "<leader>fT", "<cmd>Telescope builtin<cr>", desc = "Telescope builtins" },

    { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto definitions" },
    { "gr", "<cmd>Telescope lsp_references<cr>", desc = "Goto references" },
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
