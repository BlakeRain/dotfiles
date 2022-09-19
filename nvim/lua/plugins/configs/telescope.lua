local utils = require("core.utils");
local telescope = require("telescope");
local builtin = require("telescope.builtin");
local themes = require("telescope.themes");

local M = {}
M.setup = function()
  telescope.load_extension("file_browser")
  telescope.load_extension("fzf")
  telescope.load_extension("luasnip")
  telescope.load_extension("cheat")

  telescope.setup({
    defaults = {
      winblend = 10,
      mappings = {
        i = { ["<C-j>"] = "select_default", ["<C-h>"] = "which_key" },
        n = { ["<C-j>"] = "select_default" }
      },
      file_ignore_patterns = {
        "node_modules", "__pycache__", "package-lock.json", "yarn.lock",
        "Cargo.lock"
      }
    },
    pickers = { help_tags = { layout_config = { preview_width = 0.7 } } },
    extensions = {}
  })

  -- builtin.symbols({ sources = { "emoji", "gitmoji", "math" } })

  -- A customized spelling suggestion telescope popup that uses a small at-cursor float.
  function M.spell_check()
    builtin.spell_suggest(themes.get_cursor({
      prompt_title = "",
      layout_config = { height = 0.25, width = 0.25 }
    }))
  end

  utils.map("n", "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
  utils.map("n", "<leader>fcc", "<cmd>Telescope git_commits<cr>")
  utils.map("n", "<leader>fcb", "<cmd>Telescope git_bcommits<cr>")
  utils.map("n", "<leader>fcs", "<cmd>Telescope git_status<cr>")
  utils.map("n", "<leader>fd", "<cmd>Telescope lsp_document_symbols<cr>")
  utils.map("n", "<leader>fD", "<cmd>Telescope diagnostics<cr>")
  utils.map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
  utils.map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
  utils.map("n", "<leader>fG", "<cmd>Telescope grep_string<cr>")
  utils.map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
  utils.map("n", "<leader>fHc", "<cmd>Cheatsheet<cr>")
  utils.map("n", "<leader>fHC", "<cmd>Telescope cheat fd<cr>")
  utils.map("n", "<leader>fj", "<cmd>Telescope jumplist<cr>")
  utils.map("n", "<leader>fl", "<cmd>Telescope luasnip<cr>")
  utils.map("n", "<leader>fm", "<cmd>Telescope marks<cr>")
  utils.map("n", "<leader>fM", "<cmd>Telescope man_pages<cr>")
  utils.map("n", "<leader>fr", "<cmd>Telescope registers<cr>")
  utils.map("n", "<leader>fR", "<cmd>Telescope resume<cr>")
  utils.map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>")
  utils.map("n", "<leader>fs", M.spell_check, { desc = "Spelling Suggestions" })
  utils.map("n", "<leader>ft", "<cmd>TodoTelescope<cr>")
  utils.map("n", "<leader>fT", "<cmd>Telescope builtin<cr>")

  utils.map("n", "gd", "<cmd>Telescope lsp_definitions<cr>")
  utils.map("n", "gr", "<cmd>Telescope lsp_references<cr>")
end

return M
