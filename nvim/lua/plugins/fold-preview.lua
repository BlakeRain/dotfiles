-- Preview of folds
-- https://github.com/anuvyklack/fold-preview.nvim
--
-- This displays a floating preview of a fold when we press 'h' and opens the fold if we press 'l'. Quite a simple
-- and effective plugin.

local M = {
  'anuvyklack/fold-preview.nvim',
  dependencies = { 'anuvyklack/keymap-amend.nvim' },
  event = "VeryLazy"
}

function M.config()
  require('fold-preview').setup()
end

return M
