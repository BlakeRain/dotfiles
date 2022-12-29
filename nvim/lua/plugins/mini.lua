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
end

return M
