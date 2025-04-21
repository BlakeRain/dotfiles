local LINE_RE = "^%s*(.-)%s+([%-%d%.]+)%s+(%a+)%s*$"
local LINE_FMT = "  %-38s  %9s %s"

vim.bo.commentstring = "# %s"

local function swap_lines()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  local next_line_no = row + 1
  if next_line_no > vim.api.nvim_buf_line_count(0) then
    vim.notify("Cannot swap with the last line", vim.log.levels.ERROR)
    return
  end

  local current_line = vim.api.nvim_get_current_line()
  local next_line = vim.api.nvim_buf_get_lines(0, next_line_no - 1, next_line_no, false)[1]

  local account, amount, currency = string.match(current_line, LINE_RE)
  local next_acc = string.match(next_line, "^%s*(.-)%s*$")

  if string.sub(amount, 1, 1) == '-' then
    amount = string.sub(amount, 2)
  else
    amount = "-" .. amount
  end

  local new_cur_line = string.format(LINE_FMT, next_acc, amount, currency)
  local new_next_line = "  " .. account

  vim.api.nvim_buf_set_lines(0, next_line_no - 1, next_line_no, false, { new_next_line })
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_cur_line })
  vim.api.nvim_win_set_cursor(0, { next_line_no, col })

  vim.notify("Swapped lines", vim.log.levels.INFO)
end

local function format_line()
  local current_line = vim.api.nvim_get_current_line()
  local account, amount, currency = string.match(current_line, LINE_RE)
  local new_line = string.format(LINE_FMT, account, amount, currency)
  vim.api.nvim_set_current_line(new_line)
end

local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>hs", function()
  swap_lines()
end, { buffer = bufnr, noremap = true, silent = true, desc = "Swap lines" })

vim.keymap.set("n", "<leader>hf", function()
  format_line()
end, { buffer = bufnr, noremap = true, silent = true, desc = "Format line" })
