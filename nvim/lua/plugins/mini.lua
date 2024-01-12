-- Collection of minimal modules for Neovim
-- https://github.com/echasnovski/mini.nvim

local M = {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
}

function M.config()
  require("mini.indentscope").setup({})

  require("mini.cursorword").setup({
    -- Delay (in ms) between when the cursor moved and when the highlighting appears.
    delay = 250
  })

  require("mini.align").setup({
    mappings = {
      start = "",
      start_with_preview = "gA"
    }
  })

  require("mini.ai").setup({
    custom_text_objects = nil
  })


  vim.keymap.set("n", "<leader>bz", function()
    require("mini.misc").zoom(0, {})
  end, { desc = "Zoom into buffer" })

  require("mini.bracketed").setup({})

  require("mini.files").setup({})
  vim.keymap.set("n", "<leader>o", function()
    require("mini.files").open()
  end, { desc = "Open file browser" })

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
end

return M
