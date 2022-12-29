-- Collection of minimal modules for Neovim
-- https://github.com/echasnovski/mini.nvim

local M = {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
}

function M.setup_animate()
  local mouse_scrolled = false
  for _, scroll in ipairs({ "Up", "Down" }) do
    local key = "<ScrollWheel" .. scroll .. ">"
    vim.keymap.set("", key, function()
      mouse_scrolled = true
      return key
    end, { remap = true, expr = true })
  end

  local animate = require("mini.animate")
  vim.go.winwidth = 20
  vim.go.winminwidth = 5

  animate.setup({
    resize = {
      timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
    },
    scroll = {
      timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
      subscroll = animate.gen_subscroll.equal({
        predicate = function(total_scroll)
          if mouse_scrolled then
            mouse_scrolled = false
            return false
          end
          return total_scroll > 1
        end,
      }),
    },
  })
end

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

  M.setup_animate()
end

return M
