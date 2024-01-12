-- Collection of minimal modules for Neovim
-- https://github.com/echasnovski/mini.nvim

local M = {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
}

function M.config()
  ------------------------------------------------------------------------------------------------

  require("mini.align").setup({
    mappings = {
      start = "",
      start_with_preview = "gA"
    }
  })

  ------------------------------------------------------------------------------------------------

  require("mini.ai").setup({
    custom_text_objects = nil
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
        { mode = "n", keys = "<leader>f",       desc = "+Telescope" },
        { mode = "n", keys = "<leader>fc",      desc = "+Telescope commits" },
        { mode = "n", keys = "<leader>fH",      desc = "+Telescope cheats" },
        { mode = "n", keys = "<leader>g",       desc = "+Git (& others)" },
        { mode = "n", keys = "<leader>gh",      desc = "+Git hunks" },
        { mode = "n", keys = "<leader>gp",      desc = "+Goto preview" },
        { mode = "n", keys = "<leader>j",       desc = "+Jump" },
        { mode = "n", keys = "<leader>n",       desc = "+Noice" },
        { mode = "n", keys = "<leader>q",       desc = "+Quickfix" },
        { mode = "n", keys = "<leader>w",       desc = "+Windows" },
        { mode = "n", keys = "<leader>x",       desc = "+Trouble" },
      }
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

  require("mini.files").setup({})
  vim.keymap.set("n", "<leader>o", function()
    require("mini.files").open()
  end, { desc = "Open file browser" })

  ------------------------------------------------------------------------------------------------

  require("mini.indentscope").setup({})

  ------------------------------------------------------------------------------------------------

  require("mini.jump").setup({
  })

  local mocha = require("catppuccin.palettes").get_palette "mocha"
  vim.api.nvim_set_hl(0, "MiniJump", {
    fg = mocha.base,
    bg = mocha.yellow,
  })

  local jump2d = require("mini.jump2d")
  jump2d.setup({
    mappings = {
      start_jumping = "",
    }
  })

  vim.keymap.set("n", "<leader>jj", function()
    jump2d.start(jump2d.builtin_opts.word_start)
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

  local notify = require("mini.notify")
  notify.setup({
    content = {
      format = function(notif)
        return string.format("• %s", notif.msg)
      end
    },
    lsp_progress = {
      enabled = true
    },
    window = {
      winblend = 10
    }
  })

  vim.notify = notify.make_notify()
  vim.keymap.set("n", "<leader>fn", function()
    notify.show_history()
  end, { desc = "Show notification history" })

  ------------------------------------------------------------------------------------------------

  require("mini.pairs").setup({
  })
end

return M
