local curl = require("plenary.curl")
local ts_utils = require("nvim-treesitter.ts_utils")
local notify = require("notify")

local function load_keyfile(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return vim.json.decode(content)
end

local function get_node_text(node)
  local lines = ts_utils.get_node_text(node)
  return table.concat(lines, "\n")
end

local function get_function_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if not node then return nil end

  while node do
    local t = node:type()
    if t == "function_definition" or t == "function_declaration" then break end
    node = node:parent()
  end

  if not node then return nil end
  local startline, startcol, endline, endcol = node:range()
  local text = get_node_text(node)

  return {
    start = { line = startline, col = startcol },
    finish = { line = endline, col = endcol },
    text = text
  }
end

local function split_lines(input)
  local result = {}
  local from = 1

  local ds, de = string.find(input, "\n", from, true)
  while ds do
    if ds ~= 1 then table.insert(result, string.sub(input, from, ds - 1)) end
    from = de + 1
    ds, de = string.find(input, "\n", from, true)
  end

  if from < #input then table.insert(result, string.sub(input, from)) end
  return result
end

local function get_comment_wrapper(bufnr)
  local cs = vim.api.nvim_buf_get_option(bufnr, "commentstring")
  if cs:find("%%s") then
    local left, right = cs:match("^(.*)%%s(.*)")
    if not left:match("%s$") then left = left .. " " end

    if right and not right:match("^%s") then right = " " .. right end

    return left, right
  else
    print("Current commentstring is not understood: '" .. cs .. "'")
    return nil
  end
end

local function comment_lines(width, left, right, indent, text)
  local lines = {}
  local line = nil

  for word in string.gmatch(text, "([^%s]+)") do
    if line == nil then
      line = string.rep(" ", indent) .. left .. word
    elseif #line + #word + #right + 1 >= width then
      table.insert(lines, line .. right)
      line = string.rep(" ", indent) .. left .. word
    else
      line = line .. " " .. word
    end
  end

  if #line > 0 then table.insert(lines, line .. right) end

  return lines
end

local function insert_comment(bufnr, code, text)
  local width = vim.api.nvim_buf_get_option(bufnr, "textwidth")
  local left, right = get_comment_wrapper(bufnr)
  local lines = comment_lines(width, left, right, code.start.col, text)
  vim.api.nvim_buf_set_lines(bufnr, code.start.line, code.start.line, false,
                             lines)
end

local M = {}

local DEFAULT_CONFIG = {
  key_path = vim.fn.expand("$HOME/.openai.secret-key.json")
}

M.setup = function(config)
  config = vim.tbl_extend("force", {}, DEFAULT_CONFIG, config or {})
  local keyfile = load_keyfile(config.key_path)
  if keyfile == nil then
    error("Failed to load keyfile at '" .. config.key_path .. "'")
  end

  local secret_key = keyfile.secretKey
  if type(secret_key) ~= "string" then
    error("Expected 'secretKey' field to be present and to be a string")
  end

  M.secret_key = secret_key
  M.mark_namespace = vim.api.nvim_create_namespace("")
end

M.last_buf_id = nil

M._execute = function(prompt, suffix, callback)
  curl.post("https://api.openai.com/v1/completions", {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. M.secret_key
    },
    body = vim.json.encode({
      model = "text-davinci-003",
      temperature = 0.4,
      max_tokens = 1000,
      top_p = 1.0,
      frequency_penalty = 0.0,
      presence_penalty = 0.0,
      prompt = prompt,
      suffix = suffix
    }),
    callback = function(res)
      if type(res.body) == "string" then
        res.body = vim.json.decode(res.body)
      end

      callback(res)
    end
  })
end

M.query = function()
  local prompt = vim.fn.input("Enter prompt: ")
  if prompt == nil or #prompt == 0 then return end

  notify("Sending request to OpenAI:\n\n> " .. prompt, vim.log.levels.INFO, {
    title = "OpenAI Tools: Query",
    on_open = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end
  })

  M._execute("Using markdown, answer the query: " .. prompt, nil, function(res)
    if #res.body.choices == 0 then
      print("No response from OpenGPT")
      return
    end

    local choice = res.body.choices[1]
    vim.schedule(function()
      -- If we already have a buffer from previous output, delete it
      if M.last_buf_id ~= nil and vim.api.nvim_buf_is_valid(M.last_buf_id) then
        vim.api.nvim_buf_delete(M.last_buf_id, { force = true })
      end

      -- Create a new buffer that is not listed and is a scrath buffer
      M.last_buf_id = vim.api.nvim_create_buf(false, true)

      -- Split the current window with the new buffer
      vim.cmd("split")

      -- Set the split window to the scratch buffer
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, M.last_buf_id)

      -- Set the filetype of the scratch buffer to markdown
      vim.api.nvim_buf_set_option(M.last_buf_id, "filetype", "markdown")

      -- Write out the response from OpenGPT into the window
      local lines = split_lines(choice.text)
      table.insert(lines, 1, "> " .. prompt)
      vim.api.nvim_buf_set_lines(M.last_buf_id, 0, 0, false, lines)
    end)
  end)
end

M.explainFunction = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local code = get_function_at_cursor()
  if code == nil then
    print("Unable to find function under cursor")
    return
  end

  notify("Sending request to OpenAI ...", vim.log.levels.INFO,
         { title = "OpenAI Tools: Explain Function" })

  M._execute("Using markdown, explain the following function:\n\n" .. code.text,
             nil, function(res)
    if #res.body.choices == 0 then
      print("No choices")
      return
    end

    local choice = res.body.choices[1]
    vim.schedule(function()
      notify(
        ("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
                                                                     .usage
                                                                     .total_tokens),
        vim.log.levels.INFO)
      insert_comment(bufnr, code, choice.text)
    end)
  end)
end

local CONTEXT_LENGTH = 20

M.complete = function()
  local buffer = vim.api.nvim_get_current_buf()
  local start_pos = vim.api.nvim_win_get_cursor(0)
  local start_row = start_pos[1] - 1
  local start_col = start_pos[2] + 1
  local end_row = start_row
  local end_col = start_col

  local start_line_length = vim.api.nvim_buf_get_lines(buffer, start_row,
                                                       start_row + 1, true)[1]:len()
  start_col = math.min(start_col, start_line_length)

  local end_line_length = vim.api.nvim_buf_get_lines(buffer, end_row,
                                                     end_row + 1, true)[1]:len()
  end_col = math.min(end_col, end_line_length)

  local mark_id = vim.api.nvim_buf_set_extmark(buffer, M.mark_namespace,
                                               start_row, start_col, {
    end_row = end_row,
    end_col = end_col,
    hl_group = "OpenAIHighlight",
    sign_text = "O",
    sign_hl_group = "OpenAISign"
  })

  local prefix = table.concat(vim.api.nvim_buf_get_text(buffer, math.max(0,
                                                                         start_row -
                                                                           CONTEXT_LENGTH),
                                                        0, start_row, start_col,
                                                        {}), "\n")

  local line_count = vim.api.nvim_buf_line_count(buffer)
  local suffix = table.concat(vim.api.nvim_buf_get_text(buffer, end_row,
                                                        end_col, math.min(
                                                          end_row +
                                                            CONTEXT_LENGTH,
                                                          line_count - 1),
                                                        9999999, {}), "\n")

  M._execute(prompt, suffix, function(res)
    if #res.body.choices == 0 then
      print("No choices")
      return
    end

    vim.schedule(function()
      local mark = vim.api.nvim_buf_get_extmark_by_id(buffer, M.mark_namespace,
                                                      mark_id,
                                                      { details = true })
      vim.api.nvim_buf_del_extmark(buffer, M.mark_namespace, mark_id)

      local text = res.body.choices[1].text
      local lines = {}
      for line in text:gmatch("[^\n]+") do table.insert(lines, line) end

      vim.api.nvim_buf_set_text(buffer, mark[1], mark[2], mark[3].end_row,
                                mark[3].end_col, lines)
    end)
  end)
end

return M
