-- Commenting code
-- https://github.com/numToStr/Comment.nvim
local M = {
  'numToStr/Comment.nvim',
  event = { "BufReadPost", "BufNewFile" },
}

local function commented_lines_textobject()
  local utils = require("Comment.utils")
  local cl = vim.api.nvim_win_get_cursor(0)[1]
  local range = { srow = cl, scol = 0, erow = cl, ecol = 0 }
  local ctx = {
    ctype = utils.ctype.linewise,
    range = range
  }

  local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
  local ll, rr = utils.unwrap_cstr(cstr)
  local padding = true
  local is_commented = utils.is_commented(ll, rr, padding)

  local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
  if next(line) == nil or not is_commented(line[1]) then
    return
  end

  local rs, re = cl, cl
  repeat
    rs = rs - 1
    line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
  until next(line) == nil or not is_commented(line[1])

  rs = rs + 1

  repeat
    re = re + 1
    line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
  until next(line) == nil or not is_commented(line[1])

  re = re - 1

  vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

function M.config()
  local comment = require("Comment")
  local ft = require("Comment.ft")

  comment.setup()
  ft.set("groff", ".\\\"%s")
  ft.set("crontab", "#%s")
end

M.keys = {
  { "gc", commented_lines_textobject, silent = true, desc = "Textobject for adjacent commented lines", mode = "o" },
  { "u",  commented_lines_textobject, silent = true, desc = "Textobject for adjacent commented lines", mode = "o" },
}

return M
