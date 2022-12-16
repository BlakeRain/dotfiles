local M = {}

M.map = function(mode, keys, command, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end

  local valid_modes = {
    [''] = true,
    ['n'] = true,
    ['v'] = true,
    ['s'] = true,
    ['x'] = true,
    ['o'] = true,
    ['!'] = true,
    ['i'] = true,
    ['l'] = true,
    ['c'] = true,
    ['t'] = true
  }

  local function map_wrapper(sub_mode, lhs, rhs, sub_options)
    if type(lhs) == 'table' then
      for _, key in ipairs(lhs) do
        map_wrapper(sub_mode, key, rhs, sub_options)
      end
    else
      if type(sub_mode) == 'table' then
        for _, m in ipairs(sub_mode) do
          map_wrapper(m, lhs, rhs, sub_options)
        end
      else
        if valid_modes[sub_mode] and lhs and rhs then
          vim.keymap.set(sub_mode, lhs, rhs, options)
          -- vim.api.nvim_set_keymap(sub_mode, lhs, rhs, sub_options)
        else
          sub_mode, lhs, rhs = sub_mode or '', lhs or '', rhs or ''
          print(
            'Cannot set mapping [mode =' .. sub_mode .. ' | key = ' .. lhs ..
              ' | cmd = ' .. rhs .. ']')

        end
      end
    end
  end

  map_wrapper(mode, keys, command, options)
end

M.packer_lazy_load = function(plugin, timer)
  if plugin then
    timer = timer or 0
    vim.defer_fn(function() require('packer').loader(plugin) end, timer)
  end
end

M.split = function(text)
  local t = {}
  for str in string.gmatch(text, "%S+") do table.insert(t, str) end

  return t
end

M.split_lines = function(text)
  local lines = {}

  for line in string.gmatch(text, "[^\n]+") do table.insert(lines, line) end

  return lines
end

M.wrap_text_table = function(text, max_length)
  local lines = {}

  local as_lines = M.split_lines(text)
  for _, line in ipairs(as_lines) do
    if #line > max_length then
      local tmp_line = ""
      local words = M.split(line)

      for _, word in ipairs(words) do
        if #tmp_line + #word + 1 > max_length then
          table.insert(lines, tmp_line)
          tmp_line = word
        else
          tmp_line = tmp_line .. " " .. word
        end
      end

      table.insert(lines, tmp_line)
    else
      table.insert(lines, line)
    end
  end

  return lines
end

M.wrap_text = function(text, max_length)
  local lines = M.wrap_text_table(text, max_length)
  return table.concat(lines, "\n")
end

return M

