local M = {}

-- Split a string into words.
--
-- This will obliterate multiple spaces, such that `"foo  bar"` will become `{"foo","bar"}`.
function M.split(text)
  local words = {}
  for word in string.gmatch(text, "%S+") do
    table.insert(words, word)
  end

  return words
end

-- Split a string into lines.
--
-- The `preserve` argument will preserve multiple newlines if set to true; otherwise multiple newlines will be reduced
-- to a single line.
function M.split_lines(text, preserve)
  local lines = {}

  if preserve then
    local from = 1
    local ds, de = string.find(text, "\n", from, true)

    while ds do
      if ds ~= 1 then table.insert(lines, string.sub(text, from, ds - 1)) end
      from = de + 1
      ds, de = string.find(text, "\n", from, true)
    end

    if from <= #text then table.insert(lines, string.sub(text, from)) end
  else
    -- Without preserving multiple newlines, we can just use a simple split
    for line in string.gmatch(text, "[^\n]+") do table.insert(lines, line) end
  end

  return lines
end

-- Split a string into lines and wrap to a maximum width, returning the lines as a table
--
-- This function will take the string, split it into lines (respecting the `preserve` argument), and then wrapping the
-- lines that exceed the `max_length` argument.
function M.wrap_text_table(text, max_length, preserve)
  local lines = {}
  local as_lines = M.split_lines(text, preserve)
  for _, line in ipairs(as_lines) do
    if #line > max_length then
      local tmp_line = ""
      local words = M.split(line)

      for _, word in ipairs(words) do
        -- Note that we check to ensure that `tmp_line` is not empty when we commit it once it reaches `max_length`. The
        -- reason for this is to ensure that, if the string in `word` is longer than `max_length`, we don't end up
        -- writing a blank line and then skipping the word.
        if #tmp_line > 0 and #tmp_line + #word + 1 > max_length then
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

-- Wrap a string to a maximum width, returning the wrapped string
--
-- The `preserve` argument can be set to true to preserve blank lines.
function M.wrap_text(text, max_length, preserve)
  local lines = M.wrap_text_table(text, max_length, preserve)
  return table.concat(lines, "\n")
end

-- Get the comment wrapper for a buffer
--
-- This will either return a table or nil. The table contains a `left` and `right` property for the left and right
-- comment wrapper strings. If the function could not interpret the `commentstring` for the buffer, this function will
-- return nil.
function M.get_comment_wrapper(bufnr)
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

-- Take a string and turn it into a table of comment lines
--
-- This function will take a string, split it into lines, and format those lines as comments. Note that this function
-- preserves blank lines in the input by default.
--
-- The `options` argument can be a table with the following properties:
--
-- - A `width` property giving the maximum width of a line (defaults to 100),
-- - An `indent` property that allows the comment to be indented (defaults to zero), and
-- - A `wrapper` property that contains a table giving the `left` and `right` comment wrapper. If this property is not
--   present, it defaults to the result of `get_comment_wrapper` for the current buffer. If the `get_comment_wrapper`
--   cannot interpret the buffer's `commentstring` then no comment characters will be included.
function M.create_comment_lines(text, options)
  options = options or {}
  local width = options.width or 100
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

-- Add a comment to a buffer at the specified location.
--
-- This function uses the `create_comment_lines` function to create the lines of text. The indent of the comment is
-- equal to the `column` argument.
function M.add_comment(bufnr, line, column, text)
  local lines = M.create_comment_lines(text, {
    width = vim.api.nvim_buf_get_option(bufnr, "textwidth"),
    indent = column,
    wrapper = M.get_comment_wrapper(bufnr)
  })

  vim.api.nvim_buf_set_lines(bufnr, line, line, false, lines)
end

-- Attempt to find the function at the cursor location.
function M.get_function_at_cursor(winid)
  local node = require("nvim-treesitter.ts_utils").get_node_at_cursor(winid)
  if not node then return nil end

  while node do
    local t = node:type()
    if t == "function_definition" or t == "function_declaration" then break end
    node = node:parent()
  end

  if not node then return nil end
  local startline, startcol, endline, endcol = node:range()

  return {
    start = { line = startline, col = startcol },
    finish = { line = endline, col = endcol },
    node = node,
  }
end

-- Get the text associated with the given node.
--
-- This will return a string containing the text encapsulated by the given treesitter node.
function M.get_node_text(bufnr, node)
  local startline, startcol, endline, endcol = node:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, startline, endline + 1, false)
  lines[1] = string.sub(lines[1], startcol + 1)
  lines[#lines] = string.sub(lines[#lines], 1, endcol)

  return table.concat(lines, "\n")
end

-- Get the current selection.
--
-- This will return a table with the following properties:
--
-- - `start` being a table containing the `line` and `col` of the selection start,
-- - `end` being a table containing the `line` and `col` of the selection end, and
-- - `lines` being a table of strings being the selected text.
function M.get_selection(bufnr)
  local start = vim.api.nvim_buf_get_mark(bufnr, "<")
  local finish = vim.api.nvim_buf_get_mark(bufnr, ">")
  local start_row = start[1] - 1
  local start_col = start[2]
  local end_row = finish[1] - 1
  local end_col = finish[2] + 1

  local start_line_length = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, true)[1]:len()
  start_col = math.min(start_col, start_line_length)

  local end_line_length = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)[1]:len()
  end_col = math.min(end_col, end_line_length)

  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

  return {
    start = { line = start_row, col = start_col },
    finish = { line = end_row, col = end_col },
    lines = lines
  }
end

---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

return M
