local M = {}
M.setup = function()
  -- Set our color scheme
  vim.g.tokyonight_style = 'night'
  vim.cmd('colorscheme tokyonight-night')

  -- Set an override for the window borders
  vim.cmd [[highlight WinSeparator guifg=#313349 guibg=#1A1B27]]

  -- Set an override to make comments a little easier to perceive
  vim.cmd [[highlight Comment guifg=#7079A5]]
end

return M
