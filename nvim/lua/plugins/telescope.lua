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
    "nvim-telescope/telescope-cheat.nvim",
    "benfowler/telescope-luasnip.nvim",
    "doctorfree/cheatsheet.nvim",
    "debugloop/telescope-undo.nvim",
  },
  keys = {
    { "<leader>gc",  "<cmd>Telescope git_commits<cr>",               desc = "Show git commits" },
    { "<leader>gb",  "<cmd>Telescope git_bcommits<cr>",              desc = "Show git buffer commits" },
    { "<leader>gs",  "<cmd>Telescope git_status<cr>",                desc = "Show git status" },

    { "<leader>fb",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in buffer" },
    { "<leader>fd",  "<cmd>Telescope lsp_document_symbols<cr>",      desc = "LSP document symbols" },
    { "<leader>fD",  "<cmd>Telescope diagnostics<cr>",               desc = "Filter diagnostics" },
    { "<leader>ff",  "<cmd>Telescope find_files<cr>",                desc = "Filter files" },
    { "<leader>fF",  "<cmd>Telescope oldfiles<cr>",                  desc = "Filter recent files" },
    -- { "<leader>fg",  "<cmd>Telescope live_grep<cr>",                 desc = "Live grep" },
    { "<leader>fG",  "<cmd>Telescope grep_string<cr>",               desc = "Live grep string" },
    { "<leader>fh",  "<cmd>Telescope help_tags<cr>",                 desc = "Help tags" },
    { "<leader>fHc", "<cmd>Cheatsheet<cr>",                          desc = "Cheatsheet" },
    { "<leader>fj",  "<cmd>Telescope jumplist<cr>",                  desc = "Filter jumplist" },
    { "<leader>fl",  "<cmd>Telescope luasnip<cr>",                   desc = "Filter luasnip snippets" },
    { "<leader>fm",  "<cmd>Telescope marks<cr>",                     desc = "Filter marks" },
    { "<leader>fM",  "<cmd>Telescope man_pages<cr>",                 desc = "Man pages" },
    { "<leader>fr",  "<cmd>Telescope registers<cr>",                 desc = "Filter registers" },
    { "<leader>fR",  "<cmd>Telescope resume<cr>",                    desc = "Telescope resume" },
    { "<leader>fS",  "<cmd>Telescope lsp_workspace_symbols<cr>",     desc = "LSP workspace symbols" },
    { "<leader>fs",  spell_check,                                    { desc = "Spelling Suggestions" }, desc = "Spelling suggestions" },
    { "<leader>ft",  "<cmd>TodoTelescope<cr>",                       desc = "Telescope todos" },
    { "<leader>fT",  "<cmd>Telescope builtin<cr>",                   desc = "Telescope builtins" },
    { "<leader>fu",  "<cmd>Telescope undo<cr>",                      desc = "Telescope undo" },

    { "gd",          "<cmd>Telescope lsp_definitions<cr>",           desc = "Goto definitions" },
    { "gr",          "<cmd>Telescope lsp_references<cr>",            desc = "Goto references" },
  },
}

function M.config()
  local telescope = require("telescope")

  telescope.setup({
    defaults = {
      winblend = 0,
      -- winblend = 10,
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
      find_files = {
        theme = "ivy",
        prompt_prefix = "🔍 ",
      },
      notify = {
        layout_strategy = "vertical"
      },
      help_tags = { layout_config = { preview_width = 0.7 } },
      live_grep = {
        theme = "ivy",
        prompt_prefix = "🔍 ",
      }
    },
    extensions = {
      fzf = {
        fuzzy = true,
        case_mode = "smart_case",
        override_generic_sorter = true,
        override_file_sorter = true,
      }
    }
  })

  telescope.load_extension("attempt")
  telescope.load_extension("fzf")
  telescope.load_extension("undo")

  local live_multigrep = function(opts)
    opts = opts
    opts.cwd = opts.cwd or vim.uv.cwd();

    local finder = require("telescope.finders").new_job(function(prompt)
        if not prompt or prompt == "" then
          return nil
        end

        local pieces = vim.split(prompt, "  ")
        local args = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column",
          "--smart-case" }

        if pieces[1] then
          table.insert(args, "-e")
          table.insert(args, pieces[1])
        end

        if pieces[2] then
          local arg = pieces[2]

          -- If the argument doesn't look like a glob (it's just letters), then turn it into a glob.

          if arg == '' or arg:match("^[%w]+$") then
            arg = "*" .. arg .. "*"
          end

          print("arg", arg)

          table.insert(args, "-g")
          table.insert(args, arg)
        end

        return args
      end,
      require("telescope.make_entry").gen_from_vimgrep(opts), opts.max_results, opts.cwd)

    require("telescope.pickers").new(opts, {
      debounce = 100,
      finder = finder,
      prompt_title = "Live Grep",
      previewer = require("telescope.config").values.grep_previewer(opts),
      sorter = require("telescope.sorters").highlighter_only(opts),
      attach_mappings = function(_, map)
        map("i", "<c-space>", require("telescope.actions").to_fuzzy_refine)
        return true
      end,
      push_cursor_on_edit = true,
    }):find()
  end

  vim.keymap.set("n", "<leader>fg", function()
    live_multigrep(require("telescope.themes").get_ivy({}))
  end, { desc = "Live grep" })

  -- Solution for telescope opening file in insert mode
  -- See https://github.com/nvim-telescope/telescope.nvim/issues/2501#issuecomment-1561838990
  vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
      if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "i", false)
      end
    end
  })

  vim.keymap.set("n", "<leader>en", function()
    require("telescope.builtin").find_files {
      cwd = vim.fn.stdpath("config")
    }
  end, { desc = "Search in Neovim Config" })

  vim.keymap.set("n", "<leader>ep", function()
    require("telescope.builtin").find_files {
      cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
    }
  end, { desc = "Search in Neovim Plugins" })
end

return M
