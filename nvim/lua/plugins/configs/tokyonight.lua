local M = {}
M.setup = function()
  -- Set our color scheme
  vim.g.tokyonight_style = 'night'
  vim.cmd('colorscheme tokyonight-night')

  -- Set an override for the window borders
  vim.cmd [[highlight WinSeparator guifg=#313349 guibg=#1A1B27]]
end

return M
