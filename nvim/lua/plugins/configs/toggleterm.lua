local toggleterm = require("toggleterm")
local Terminal = require("toggleterm.terminal").Terminal
local utils = require("core.utils")

local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  float_opts = { winblend = 5 }
})

local floating = Terminal:new({
  hidden = true,
  direction = "float",
  float_opts = { width = 120, height = 50, winblend = 5 }
})

function _G._lazygit_toggle() lazygit:toggle() end
function _G._floating_toggle() floating:toggle() end

-- This function gets called when we create a new terminal to assign the keymaps
function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

local M = {}
M.setup = function()
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

  vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

  -- Toggle our standard floating terminal
  utils.map("n", "<Leader>t", "<cmd> lua _floating_toggle()<CR>",
            { noremap = true, silent = true })

  -- Toggle a terminal at the bottom of the window
  utils.map("n", "<Leader>T", "<cmd>ToggleTerm<CR>", { noremap = true })

  -- Toggle a floating LazyGit window
  utils.map("n", "<Leader>gg", "<cmd>lua _lazygit_toggle()<CR>",
            { noremap = true, silent = true })
end

return M

