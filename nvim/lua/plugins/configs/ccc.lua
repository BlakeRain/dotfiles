local ccc = require("ccc");
local utils = require("core.utils")

local M = {}
M.setup = function()
  ccc.setup({ inputs = { ccc.input.hsl, ccc.input.rgb } })

  utils.map("n", "<leader>cc", "<CMD>CccPick<CR>",
            { desc = "Change color", silent = true })

  local color_group = vim.api.nvim_create_augroup("ColorPickerSets",
                                                  { clear = true })
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.css", "*.scss", "*.sass", "*.less" },
    group = color_group,
    callback = function()
      utils.map("i", "<C-c>", "<Plug>(ccc-insert)", { silent = true })
    end
  })

end

return M
