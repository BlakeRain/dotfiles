-- Collection of minimal modules for Neovim
-- https://github.com/echasnovski/mini.nvim

local M = {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
}

function M.config()
  local mocha = require("catppuccin.palettes").get_palette "mocha"

  ------------------------------------------------------------------------------------------------

  require("mini.align").setup({
    mappings = {
      start = "",
      start_with_preview = "gA"
    }
  })

  ------------------------------------------------------------------------------------------------

  local ts_spec = require("mini.ai").gen_spec.treesitter
  require("mini.ai").setup({
    custom_textobjects = {
      F = ts_spec({
        a = "@function.outer",
        i = "@function.inner",
      }),
      o = ts_spec({
        a = { "@conditional.outer", "@loop.outer" },
        i = { "@conditional.inner", "@loop.inner" },
      }),
    }
  })

  ------------------------------------------------------------------------------------------------

  require("mini.bracketed").setup({})

  ------------------------------------------------------------------------------------------------

  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },

      -- Brackets (mini.bracketed)
      { mode = 'n', keys = ']' },
      { mode = 'n', keys = '[' },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),

      {
        { mode = "n", keys = "<Leader>c",       desc = "+Code" },
        { mode = "n", keys = "<leader><space>", desc = "Toggle folded region" },
        { mode = "n", keys = "<leader>a",       desc = "+Attempt" },
        { mode = "n", keys = "<leader>b",       desc = "+Buffers" },
        { mode = "n", keys = "<leader>c",       desc = "+Code" },
        { mode = "n", keys = "<leader>C",       desc = "+Cargo" },
        { mode = "n", keys = "<leader>cR",      desc = "+Rust" },
        { mode = "n", keys = "<leader>co",      desc = "+Code & OpenAI" },
        { mode = "n", keys = "<leader>cw",      desc = "+LSP workspace" },
        { mode = "n", keys = "<leader>e",       desc = "+Editor" },
        { mode = "n", keys = "<leader>f",       desc = "+Telescope" },
        -- { mode = "n", keys = "<leader>fc",      desc = "+Telescope commits" },
        { mode = "n", keys = "<leader>fH",      desc = "+Telescope cheats" },
        { mode = "n", keys = "<leader>g",       desc = "+Git (& others)" },
        { mode = "n", keys = "<leader>gh",      desc = "+Git hunks" },
        { mode = "n", keys = "<leader>gp",      desc = "+Goto preview" },
        { mode = "n", keys = "<leader>j",       desc = "+Jump" },
        { mode = "n", keys = "<leader>n",       desc = "+Noice" },
        { mode = "n", keys = "<leader>q",       desc = "+Quickfix" },
        { mode = "n", keys = "<leader>w",       desc = "+Windows" },
        { mode = "n", keys = "<leader>x",       desc = "+Trouble" },
      },
    },

    window = {
      -- Floating window config
      config = {
        width = "auto"
      }
    }
  })

  ------------------------------------------------------------------------------------------------

  require("mini.comment").setup({
  })

  ------------------------------------------------------------------------------------------------

  require("mini.cursorword").setup({
    -- Delay (in ms) between when the cursor moved and when the highlighting appears.
    delay = 250
  })

  ------------------------------------------------------------------------------------------------

  require("mini.files").setup({
    options = {
      use_as_default_explorer = true,
    },
    windows = {
      winblend = 0,
      preview = true,
      width_preview = 80,
    }
  })

  vim.keymap.set("n", "<leader>o", function()
    local files = require("mini.files")
    if not files.close() then
      files.open(vim.api.nvim_buf_get_name(0), true)
    end
  end, { desc = "Open file browser" })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesWindowOpen",
    callback = function(args)
      local win_id = args.data.win_id
      vim.wo[win_id].winblend = 0

      local config = vim.api.nvim_win_get_config(win_id)
      config.border = "double"
      vim.api.nvim_win_set_config(win_id, config)
    end
  })
  ------------------------------------------------------------------------------------------------

  require("mini.indentscope").setup({})

  vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", {
    fg = mocha.mauve
  })

  ------------------------------------------------------------------------------------------------

  require("mini.jump").setup({
  })

  vim.api.nvim_set_hl(0, "MiniJump", {
    fg = mocha.base,
    bg = mocha.yellow,
  })

  vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { reverse = true })
  vim.api.nvim_set_hl(0, 'MiniJump2dSpotUnique', { reverse = true })

  local jump2d = require("mini.jump2d")
  jump2d.setup({
    allowed_lines = {
      blank = false,
    },
    allowed_windows = {
      current = true,
      not_current = false,
    },
    mappings = {
      start_jumping = "",
    }
  })

  vim.keymap.set("n", "<leader>jj", function()
    -- jump2d.start(jump2d.builtin_opts.word_start)
    jump2d.start({ spotter = jump2d.gen_pattern_spotter("[%w_]+", "start") })
  end, { desc = "Jump to word" })

  vim.keymap.set("n", "<leader>jl", function()
    jump2d.start(jump2d.builtin_opts.line_start)
  end, { desc = "Jump to line" })

  vim.keymap.set("n", "<leader>jc", function()
    jump2d.start(jump2d.builtin_opts.single_character)
  end, { desc = "Jump to input char" })

  vim.keymap.set("n", "<leader>jq", function()
    jump2d.start(jump2d.builtin_opts.query)
  end, { desc = "Jump to input word" })

  ------------------------------------------------------------------------------------------------

  vim.keymap.set("n", "<leader>bz", function()
    require("mini.misc").zoom(0, {})
  end, { desc = "Zoom into buffer" })

  ------------------------------------------------------------------------------------------------

  require('mini.move').setup({})

  ------------------------------------------------------------------------------------------------

  local notify = require("mini.notify")
  notify.setup({
    content = {
      format = function(notif)
        return string.format("• %s", notif.msg)
      end
    },
    lsp_progress = {
      enable = false
    },
    window = {
      winblend = 0
      -- winblend = 10
    }
  })

  vim.notify = notify.make_notify()
  vim.keymap.set("n", "<leader>fn", function()
    notify.show_history()
  end, { desc = "Show notification history" })

  ------------------------------------------------------------------------------------------------

  require("mini.pairs").setup({
  })

  ------------------------------------------------------------------------------------------------

  local SESSION_NAME = ".session.vim"
  require("mini.sessions").setup({
    file = SESSION_NAME,
    hooks = {
      pre = {
        write = function()
          -- https://github.com/romgrk/barbar.nvim?tab=readme-ov-file#mininvim
          vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
        end
      }
    }
  })

  vim.keymap.set("n", "<leader>es", function()
    -- If the 'Session.vim' file does not exist, create the new session and then notify that
    -- the new session has been created. Otherwise, load the session.
    local path = vim.fn.getcwd() .. "/" .. SESSION_NAME
    local stat = vim.loop.fs_stat(path)
    local sessions = require("mini.sessions")

    if stat and stat.type == "file" then
      sessions.read(SESSION_NAME)
      vim.notify("Session loaded", vim.log.levels.INFO)
    else
      sessions.write(SESSION_NAME)
      vim.notify("Session created", vim.log.levels.INFO)
    end
  end, { desc = "Load/Create session" })

  ------------------------------------------------------------------------------------------------

  require("mini.trailspace").setup({
  })
end

return M
