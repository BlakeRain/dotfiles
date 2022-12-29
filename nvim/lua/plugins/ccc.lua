-- Color picker
-- https://github.com/uga-rosa/ccc.nvim
--
-- This plugin adds a color picker that we can display with '<Leader>cc'. If there is a color at the cursor, it will
-- allow us to edit that color; otherwise it will create a new color.

local M = {
  "uga-rosa/ccc.nvim",
  branch = "0.7.2",
  event = {},
  cmd = {
    "CccPick",
    "CccConvert",
  },
  keys = {
    -- { "<C-c>", "<Plug>(ccc-insert)", mode = "i" },
    { "<leader>cc", "<cmd>CccPick<cr>", desc = "Change color" }
  },
}

local EXTENSIONS = { "*.css", "*.scss", "*.sass", "*.less" }
for _, extension in ipairs(EXTENSIONS) do
  table.insert(M.event, "BufRead " .. extension)
  table.insert(M.event, "BufNewFile " .. extension)
end

function M.config()
  local ccc = require("ccc")
  ccc.setup({ inputs = { ccc.input.hsl, ccc.input.rgb } })

  local color_group = vim.api.nvim_create_augroup("ColorPickerSets", { clear = true })
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.css", "*.scss", "*.sass", "*.less" },
    group = color_group,
    callback = function()
      vim.keymap.set("i", "<C-c>", "<Plug>(ccc-insert)", { silent = true })
    end
  })
end

return M
