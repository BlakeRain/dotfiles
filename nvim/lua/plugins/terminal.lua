-- Persist and toggle terminals
-- https://github.com/akinsho/toggleterm.nvim

local M = {
  "akinsho/toggleterm.nvim",
  keys = {
    { "<leader>T", "<cmd>ToggleTerm<cr>", desc = "Toggle bottom terminal" },
    { "<leader>t", function() require("plugins.terminal").toggle_floating() end, desc = "Toggle terminal" },
    { "<leader>gg", function() require("plugins.terminal").toggle_lazygit() end, desc = "Lazygit window" },
  }
}

-- This function gets called when we create a new terminal to assign the keymaps
function M.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

function M.toggle_lazygit()
  if M.lazygit == nil then
    local Terminal = require("toggleterm.terminal").Terminal
    M.lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      float_opts = { winblend = 5 }
    })
  end

  M.lazygit:toggle()
end

function M.toggle_floating()
  if M.floating == nil then
    local Terminal = require("toggleterm.terminal").Terminal
    M.floating = Terminal:new({
      hidden = true,
      direction = "float",
      float_opts = { width = 120, height = 50, winblend = 5 }
    })
  end

  M.floating:toggle()
end

function M.config()
  local toggleterm = require("toggleterm")

  toggleterm.setup({
    size = function(term)
      if term.direction == "horizontal" then
        return 30
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    -- open_mapping = '<Leader>t',
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    close_on_exit = true,
    float_opts = { border = "curved", winblend = 3 }
  })

  vim.cmd('autocmd! TermOpen term://* lua require("plugins.terminal").set_terminal_keymaps()')
end

return M
