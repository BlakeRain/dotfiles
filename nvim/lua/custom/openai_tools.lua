local utils = require('core.utils')
local curl = require("plenary.curl")

-- local MODEL = "text-davinci-003"
-- local MODEL = "gpt-3.5-turbo"
local MODEL = "gpt-4-1106-preview"

-- Load the keyfile from the given location. The keyfile is expected to be a JSON file that provides the key in a
-- `secretKey` field.
--
-- For example:
--
-- ```json
-- { "secretKey": "..." }
-- ```
local function load_keyfile(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return vim.json.decode(content)
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

  vim.api.nvim_set_hl(0, "OpenAISign", { fg = "#2ac3de" })

  vim.api.nvim_create_user_command("OpenAIQuery",
    function(args) M.query(args) end,
    { range = true, nargs = "*" })

  vim.api.nvim_create_user_command("OpenAIExplainCode",
    function() M.explain_code() end,
    { range = true })

  vim.api.nvim_create_user_command("OpenAIExplainFunction",
    function() M.explain_function() end, {})

  vim.api.nvim_create_user_command("OpenAIComplete",
    function() M.complete() end, {})

  vim.api.nvim_create_user_command("OpenAICommitMessage",
    function() M.commit_message() end, {})
end

M.last_buf_id = nil

M._mark_lines = function(bufnr, from, to)
  for i = from, to do
    vim.api.nvim_buf_set_extmark(bufnr, M.mark_namespace, i, -1, {
      id = i,
      sign_text = i == from and "ﮧ" or "│",
      sign_hl_group = "OpenAISign"
    })
  end
end

-- URL = "https://api.openai.com/v1/completions"
URL = "https://api.openai.com/v1/chat/completions"

M.log_message = function(message)
  local log_path = vim.fn.expand("$HOME/.openai.log")
  if type(log_path) ~= "string" then return end

  -- Append the message to the log file
  local file = io.open(log_path, "a")
  if file == nil then
    vim.notify(("Unable to append to log file '%s'"):format(log_path))
    return
  end
  file:write(vim.fn.strftime("%Y-%m-%d %H:%M:%S") .. " " .. message .. "\n")
  file:flush()
  file:close()
end

M._execute = function(messages, callback, opts)
  opts = opts or {}
  if type(messages) == "string" then
    messages = {
      { role = "user", content = messages }
    }
  end

  local body = vim.json.encode({
    model = MODEL,
    messages = messages,
    temperature = opts.temperature or 0,
    top_p = opts.top_p or 1.0,
    n = 1,
    stream = false,
    max_tokens = opts.max_tokens or 1000,
    presence_penalty = opts.presence_penalty or 0.0,
    frequency_penalty = opts.frequency_penalty or 0.0,
  })

  M.log_message(("POST to %s:\n\t%s"):format(URL, vim.inspect(body)))

  curl.post(URL, {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. M.secret_key
    },
    body = body,
    callback = function(res)
      vim.schedule(function()
        M.log_message(("Response from %s:\n\t%s"):format(URL, vim.inspect(res)))
      end)
      if type(res.body) == "string" then
        res.body = vim.json.decode(res.body)
      end

      callback(res)
    end
  })
end

M.query = function(args)
  args = args or {}
  local prompt = args.args
  local display_prompt = prompt
  local visual = args.range > 0

  if visual then
    local bufnr = vim.api.nvim_get_current_buf()
    local selection = utils.get_selection(bufnr)
    prompt = table.concat(selection.lines, "\n")
    display_prompt = "(visual selection)"
  else
    if prompt == nil or #prompt == 0 then
      local okay, received = pcall(vim.fn.input, "Enter prompt: ")
      if not okay or received == nil or #received == 0 then return end
      prompt = received
      display_prompt = prompt
    end
  end

  vim.notify("Sending request to OpenAI:\n\n> " .. display_prompt,
    vim.log.levels.INFO, {
      title = "OpenAI Tools: Query",
      on_open = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
      end
    })

  M._execute(prompt, function(res)
    if #res.body.choices == 0 then
      vim.notify("No response from OpenGPT", vim.log.levels.ERROR)
      return
    end

    local choice = res.body.choices[1]
    vim.schedule(function()
      vim.notify(
        ("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
          .usage
          .total_tokens),
        vim.log.levels.INFO, { title = "OpenAI Tools: Query" })

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

      local lines = {}

      local prompt_lines = utils.split_lines(prompt)
      for i, line in ipairs(prompt_lines) do
        if i == 1 then
          table.insert(lines, "  | " .. line)
        else
          table.insert(lines, "   | " .. line)
        end
      end

      table.insert(lines, "")

      local choice_lines = utils.split_lines(choice.message.content)
      for _, line in ipairs(choice_lines) do table.insert(lines, line) end

      vim.api.nvim_buf_set_lines(M.last_buf_id, 0, 0, false, lines)
      for index = 0, #prompt_lines do
        local start = 5
        if index == 0 then start = 7 end
        vim.api.nvim_buf_add_highlight(M.last_buf_id, -1, "ChatGPTPrompt",
          index, start, -1)
      end
    end)
  end)
end

M.explain_function = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local code = utils.get_function_at_cursor(0)
  if code == nil then
    print("Unable to find function under cursor")
    return
  end

  code.text = utils.get_node_text(bufnr, code.node)
  M._mark_lines(bufnr, code.start.line, code.finish.line)

  vim.notify("Sending request to OpenAI ...", vim.log.levels.INFO,
    { title = "OpenAI Tools: Explain Function" })

  M._execute("Using markdown, explain the following function:\n\n" .. code.text,
    function(res)
      vim.schedule(function()
        vim.notify(
          ("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
            .usage
            .total_tokens),
          vim.log.levels.INFO, { title = "OpenAI Tools: Explain Function" })

        vim.api.nvim_buf_clear_namespace(bufnr, M.mark_namespace, code.start.line,
          code.finish.line + 1)

        if #res.body.choices == 0 then
          print("No choices")
          return
        end

        local choice = res.body.choices[1].message.content
        choice = string.gsub(choice, "^%s*(.-)", "%1")

        utils.add_comment(bufnr, code.start.line, code.start.col, choice)
      end)
    end)
end

M.explain_code = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local code = utils.get_selection(bufnr)

  M._mark_lines(bufnr, code.start.line, code.finish.line)

  vim.notify("Sending request to OpenAI ...", vim.log.levels.INFO,
    { title = "OpenAI Tools: Explain Code" })

  M._execute("Using markdown, explain the following code:\n\n" ..
    table.concat(code.lines, "\n"),
    vim.schedule_wrap(function(res)
      vim.notify(("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
          .usage
          .total_tokens),
        vim.log.levels.INFO, { title = "OpenAI Tools: Explain Function" })

      vim.api.nvim_buf_clear_namespace(bufnr, M.mark_namespace, code.start.line,
        code.finish.line + 1)

      if #res.body.choices == 0 then
        print("No choices")
        return
      end

      local choice = res.body.choices[1].message.content
      choice = string.gsub(choice, "^%s*(.-)", "%1")

      local indent = code.start.col
      if #code.lines > 0 then
        local _, de = string.find(code.lines[1], "^%s*")
        indent = indent + de
      end

      utils.add_comment(bufnr, code.start.line, indent, choice)
    end))
end

local CONTEXT_LENGTH = 20

M.complete = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.api.nvim_win_get_cursor(0)
  local start_row = start_pos[1] - 1
  local start_col = start_pos[2] + 1
  local end_row = start_row
  local end_col = start_col

  local start_line_length = vim.api.nvim_buf_get_lines(bufnr, start_row,
    start_row + 1, true)[1]:len()
  start_col = math.min(start_col, start_line_length)

  local end_line_length = vim.api.nvim_buf_get_lines(bufnr, end_row,
    end_row + 1, true)[1]:len()
  end_col = math.min(end_col, end_line_length)

  local mark_id = vim.api.nvim_buf_set_extmark(bufnr, M.mark_namespace,
    start_row, start_col, {
      end_row = end_row,
      end_col = end_col,
      hl_group = "OpenAIHighlight",
      sign_text = "ﮧ",
      sign_hl_group = "OpenAISign"
    })

  local prefix_line = math.max(0, start_row - CONTEXT_LENGTH)
  local prefix = table.concat(vim.api.nvim_buf_get_text(bufnr, prefix_line, 0,
      start_row, start_col, {}),
    "\n")

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local suffix_line = math.min(end_row + CONTEXT_LENGTH, line_count - 1)
  local suffix = table.concat(
    vim.api.nvim_buf_get_text(bufnr, end_row, end_col,
      suffix_line, 9999999, {}), "\n")

  local prompt = "Complete the code below, writing your code after the line saying '<-- complete here -->'.\n\n" ..
      prefix .. "\n<-- complete here -->\n" .. suffix

  vim.notify("Sending request to OpenAI ...", vim.log.levels.INFO,
    { title = "OpenAI Tools: Complete Code" })

  M._execute(prompt, vim.schedule_wrap(function(res)
    local mark = vim.api.nvim_buf_get_extmark_by_id(bufnr, M.mark_namespace,
      mark_id, { details = true })
    vim.api.nvim_buf_del_extmark(bufnr, M.mark_namespace, mark_id)

    vim.notify(("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
        .usage
        .total_tokens),
      vim.log.levels.INFO, { title = "OpenAI Tools: Complete Code" })

    if #res.body.choices == 0 then
      print("No choices")
      return
    end

    local text = res.body.choices[1].message.content
    local lines = {}
    for line in text:gmatch("[^\n]+") do table.insert(lines, line) end

    vim.api.nvim_buf_set_text(bufnr, mark[1], mark[2], mark[3].end_row,
      mark[3].end_col, lines)
  end))
end

local COMMIT_MSG_PROMPT = [[
What follows "-------" is a git diff for a potential commit.
Reply with a Git commit message. A Git commit message should be concise, but also try to describe the important
changes in the commit. Don't include any other text but the commit message in your response.
-------
%s
-------
]]

function M.commit_message()
  -- Get the current git diff
  local diff = vim.fn.system("git --no-pager diff --cached --no-color")
  if #diff == 0 then
    diff = vim.fn.system("git --no-pager diff --no-color")
  end

  if #diff == 0 then
    vim.notify("No changes to commit", vim.log.levels.INFO)
    return
  end

  vim.notify("Sending request to OpenAI ...", vim.log.levels.INFO,
    { title = "OpenAI Tools: Commit Message" })

  M._execute(COMMIT_MSG_PROMPT:format(diff), vim.schedule_wrap(function(res)
    print(vim.inspect(res.body))
    vim.notify(("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
        .usage
        .total_tokens),
      vim.log.levels.INFO, { title = "OpenAI Tools: Commit Message" })

    if #res.body.choices == 0 then
      print("No choices")
      return
    end

    local text = res.body.choices[1].message.content
    vim.fn.setreg("+", text)
    print("Commit message copied to clipboard: " .. text)
  end), { max_tokens = 100 })
end

return M
