local utils = require("core.utils")

local M = {}
M.setup = function()
  -- Move to previous or next buffer
  utils.map("n", "<A-,>", ":BufferPrevious<CR>", { silent = true })
  utils.map("n", "<A-.>", ":BufferNext<CR>", { silent = true })

  -- Re-order current buffer
  utils.map("n", "<A-<>", ":BufferMovePrevious<CR>", { silent = true })
  utils.map("n", "<A->>", ":BufferMoveNext<CR>", { silent = true })

  -- Goto buffer in position
  utils.map("n", "<A-1>", ":BufferGoto 1<CR>", { silent = true })
  utils.map("n", "<A-2>", ":BufferGoto 2<CR>", { silent = true })
  utils.map("n", "<A-3>", ":BufferGoto 3<CR>", { silent = true })
  utils.map("n", "<A-4>", ":BufferGoto 4<CR>", { silent = true })
  utils.map("n", "<A-5>", ":BufferGoto 5<CR>", { silent = true })
  utils.map("n", "<A-6>", ":BufferGoto 6<CR>", { silent = true })
  utils.map("n", "<A-7>", ":BufferGoto 7<CR>", { silent = true })
  utils.map("n", "<A-8>", ":BufferGoto 8<CR>", { silent = true })
  utils.map("n", "<A-9>", ":BufferGoto 9<CR>", { silent = true })

  -- Pin or unpin a buffer
  utils.map("n", "<A-p>", ":BufferPin<CR>", { silent = true })

  -- Close buffer
  utils.map("n", "<A-c>", ":BufferClose<CR>", { silent = true })

  -- Magic buffer-picking mode
  utils.map("n", "<C-s>", ":BufferPick<CR>", { silent = true })

  utils.map("n", "<Leader>bc", ":BufferClose<CR>", { silent = true })
  utils.map("n", "<Leader>bC", ":BufferClose!<CR>", { silent = true })
  utils.map("n", "<Leader>bx", ":BufferCloseAllButCurrentOrPinned",
            { silent = true })
end

return M
