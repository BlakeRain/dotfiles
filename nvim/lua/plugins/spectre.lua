-- Find the enemy and replace them with dark power.
-- https://github.com/nvim-pack/nvim-spectre

local M = {
  "nvim-pack/nvim-spectre",
  keys = {
    { "<leader>Ss", "<cmd>lua require('spectre').open()<CR>", desc = "Start spectre search" },
    -- Search current word
    { "<leader>Sw", "<cmd>lua require('spectre').open_visual({ select_word = true })<CR>",
      desc = "Start spectre (current word)" },
    { "<leader>S", "<cmd>lua require('spectre').open_visual()<CR>", desc = "Start spectre (current selection)",
      mode = "v" },
    -- Search in current file
    { "<leader>Sp", "viw:lua require('spectre').open_file_search()<CR>", desc = "Start spectre in current file" }
  }
}

function M.config()
  require("spectre").setup({
    highlight = {
      search = "SpectreSearch",
      replace = "SpectreReplace"
    }
  })

  vim.api.nvim_set_hl(0, "SpectreSearch", { bg = "#224B28" })
  vim.api.nvim_set_hl(0, "SpectreReplace", { bg = "#4B2222" })
end

return M
