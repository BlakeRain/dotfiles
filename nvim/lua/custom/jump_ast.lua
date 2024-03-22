local ts_utils = require "nvim-treesitter.ts_utils"

local function leap(direction)
  local cur_node = ts_utils.get_node_at_cursor(0)
  if not cur_node then
    vim.notify("No treesitter node at cursor location", vim.log.levels.WARN,
      { title = "Jump AST" })
    return
  end

  local nodes = { cur_node }
  local parent = cur_node:parent()
  while parent do
    table.insert(nodes, parent)
    parent = parent:parent()
  end

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local targets = {}

  local function add_target(line, column)
    local text = vim.fn.getline(line)
    local index = vim.str_byteindex(text, math.min(math.max(column, 0), text:len())) + 1

    if targets[line] == nil then targets[line] = {} end
    for _, target in ipairs(targets[line]) do
      if target == index then return end
    end

    table.insert(targets[line], index)
  end

  for _, node in ipairs(nodes) do
    local startline, startcol, endline, endcol = node:range(false)

    startline = startline + 1
    endline = endline + 1

    if direction == nil or
        (direction == "up" and startline >= wininfo.topline) or
        (direction == "down" and endline <= wininfo.botline) then
      add_target(startline, startcol)
      if endline > endcol or endcol > startcol then
        add_target(endline, endcol - 1)
      end
    end
  end

  if #targets == 0 then
    vim.notify("No targets to jump to", vim.log.levels.WARN, { title = "Jump AST" })
    return
  end

  require("mini.jump2d").start({
    allowed_lines = { blank = false },
    spotter = function(line_num) return targets[line_num] end
  })
end

local M = {}

M.setup = function()
  vim.keymap.set({ 'n', 'x', 'o' }, 'gt', function() leap(nil) end,
    { desc = "Jump AST (bidirectional)" })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gT', function() leap("up") end,
    { desc = "Jump AST (backward)" })
end

return M
