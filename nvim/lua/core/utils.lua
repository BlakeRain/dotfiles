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

M.split_lines = function(text, preserve)
  local lines = {}

  if preserve then
    local from = 1

    local ds, de = string.find(text, "\n", from, true)
    while ds do
      if ds ~= 1 then table.insert(lines, string.sub(text, from, ds - 1)) end
      from = de + 1
      ds, de = string.find(text, "\n", from, true)
    end

    if from < #text then table.insert(lines, string.sub(text, from)) end
  else
    -- Without preserving multiple newlines, we can just use a simple split
    for line in string.gmatch(text, "[^\n]+") do table.insert(lines, line) end
  end

  return lines
end

M.wrap_text_table = function(text, max_length, preserve)
  local lines = {}

  local as_lines = M.split_lines(text, preserve)
  for _, line in ipairs(as_lines) do
    if #line > max_length then
      local tmp_line = ""
      local words = M.split(line)

      for _, word in ipairs(words) do
        if #tmp_line + #word + 1 > max_length then
          table.insert(lines, tmp_line)
          tmp_line = word
        else
          if #tmp_line == 0 then
            tmp_line = word
          else
            tmp_line = tmp_line .. " " .. word
          end
        end
      end

      table.insert(lines, tmp_line)
    else
      table.insert(lines, line)
    end
  end

  return lines
end

M.wrap_text = function(text, max_length, preserve)
  local lines = M.wrap_text_table(text, max_length, preserve)
  return table.concat(lines, "\n")
end

M.get_comment_wrapper = function(bufnr)
  local cs = vim.api.nvim_buf_get_option(bufnr, "commentstring")
  if cs:find("%%s") then
    local left, right = cs:match("^(.*)%%s(.*)")
    if not left:match("%s$") then left = left .. " " end
    if right and not right:match("^%s") then right = " " .. right end
    return { left = left, right = right }
  else
    vim.notify("Current commentstring is not understood: '" .. cs .. "'")
    return nil
  end
end

M.create_comment_lines = function(text, options)
  options = options or {}
  local width = options.width or 120
  local indent = options.indent or 0
  local wrapper = options.wrapper or M.get_comment_wrapper(0)
  if wrapper == nil then wrapper = { left = "", right = "" } end

  local wrap_len = #wrapper.left + #wrapper.right
  local indent_str = string.rep(" ", indent)

  local lines = M.wrap_text_table(text, width - (wrap_len + indent), true)
  for index, line in ipairs(lines) do
    lines[index] = indent_str .. wrapper.left .. line .. wrapper.right
  end

  return lines
end

M.add_comment = function(bufnr, line, column, text)
  local lines = M.create_comment_lines(text, {
    width = vim.api.nvim_buf_get_option(bufnr, "textwidth"),
    indent = column,
    wrapper = M.get_comment_wrapper(bufnr)
  })

  vim.api.nvim_buf_set_lines(bufnr, line, line, false, lines)
end

return M

