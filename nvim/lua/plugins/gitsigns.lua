-- Git Signs
-- https://github.com/lewis6991/gitsigns.nvim

local M = {
  'lewis6991/gitsigns.nvim',
  event = "BufReadPre"
}

function M.config()
  local gitsigns = require("gitsigns")

  gitsigns.setup({
    current_line_blame = true,
    on_attach = function(bufnr)
      local function map(mode, l, r, opts)
        opts = opts or {}
        if type(opts) == "string" then
          opts = { desc = opts }
        end
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gitsigns.next_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      map({ 'n', 'v' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>',
        { desc = "Stage current hunk" })
      map({ 'n', 'v' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>',
        { desc = "Reset current hunk" })

      map('n', '<leader>gS', gitsigns.stage_buffer,
        { desc = "Stage current buffer" })
      map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "Reset buffer" })
      map('n', '<leader>ghu', gitsigns.undo_stage_hunk,
        { desc = "Undo stage hunk" })
      map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Preview hunk" })
      map('n', '<leader>ghb',
        function() gitsigns.blame_line({ full = true }) end,
        { desc = "Show line blame" })
      map('n', '<leader>ghB', gitsigns.toggle_current_line_blame,
        { desc = "Toggle current line blame" })
      map('n', '<leader>gd', gitsigns.diffthis,
        { desc = "Diff (against index)" })

      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end
  })
end

return M
