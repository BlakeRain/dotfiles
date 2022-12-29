local ts_utils = require "nvim-treesitter.ts_utils"
local notify = require "notify"

local function get_ast_nodes(direction)
  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local cur_node = ts_utils.get_node_at_cursor(0)
  print(cur_node)
  if not cur_node then
    notify("No treesitter node at cursor location", "error",
      { title = "Leap AST" })
    return
  end

  local nodes = { cur_node }
  local parent = cur_node:parent()
  while parent do
    table.insert(nodes, parent)
    parent = parent:parent()
  end

  local targets = {}
  local startline, startcol, endline, endcol
  for _, node in ipairs(nodes) do
    startline, startcol, endline, endcol = node:range()

    if direction == nil or direction == "up" then
      if startline + 1 >= wininfo.topline then
        local target = { node = node, pos = { startline + 1, startcol + 1 } }
        table.insert(targets, target)
      end
    end

    if direction == nil or direction == "down" then
      if endline + 1 <= wininfo.botline then
        local target = { node = node, pos = { endline + 1, endcol + 1 } }
        table.insert(targets, target)
      end
    end
  end

  if #targets > 1 then return targets end
  notify("Not enough targets to make selection", "error", { title = "Leap AST" })
  return nil
end

local function select_range(target)
  local mode = vim.api.nvim_get_mode().mode
  if not mode:match("n?o") then vim.cmd("normal! " .. mode) end
  ts_utils.update_selection(0, target.node, mode:match('V') and "linewise" or
    mode:match(' ') and "blockwise" or "charwise")
end

local function leap(direction)
  assert(direction == nil or direction == "up" or direction == "down",
    "Direction should be 'up', 'down' or nil")
  local targets = get_ast_nodes(direction)
  if targets ~= nil then
    require "leap".leap {
      targets = targets,
      backwards = direction == "up",
      action = vim.api.nvim_get_mode().mode ~= 'n' and select_range
    }
  end
end

local M = {}

M.setup = function()
  vim.keymap.set({ 'n', 'x', 'o' }, 'gt', function() leap(nil) end,
    { desc = "Leap AST (bidirectional)" })
  vim.keymap.set({ 'n', 'x', 'o' }, 'gT', function() leap("up") end,
    { desc = "Leap AST (backward)" })
end

return M
