-- Collection of minimal modules for Neovim
-- https://github.com/echasnovski/mini.nvim

local M = {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
}

function M.config()
  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-indentscope.md

  require("mini.indentscope").setup({})

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-cursorword.md

  require("mini.cursorword").setup({
    -- Delay (in ms) between when the cursor moved and when the highlighting appears.
    delay = 250
  })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md

  require("mini.align").setup({
    mappings = {
      start = "",
      start_with_preview = "gA"
    }
  })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md

  require("mini.ai").setup({
    custom_text_objects = nil
  })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-misc.md

  vim.keymap.set("n", "<leader>bz", function()
    require("mini.misc").zoom(0, {})
  end, { desc = "Zoom into buffer" })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md

  require("mini.bracketed").setup({})

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-files.md

  require("mini.files").setup({})
  vim.keymap.set("n", "<leader>o", function()
    require("mini.files").open()
  end, { desc = "Open file browser" })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-comment.md

  require("mini.comment").setup({
  })

  ------------------------------------------------------------------------------------------------
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump.md
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump2d.md

  require("mini.jump").setup({
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
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-notify.md

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
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md

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
end

return M
