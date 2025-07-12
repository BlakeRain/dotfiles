local M = {
  'github/copilot.vim',
  lazy = false
}

-- Do not map tab to accept suggestions
vim.g.copilot_no_tab_map = true

vim.keymap.set('i', '<C-A>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

return M
