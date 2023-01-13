local utils = require("core.utils")
local Config = require("custom.chatgpt.config")

local highlight_ns = vim.api.nvim_create_namespace("")

-- How many blank spaces to insert after a message of the given type.
local function lead_for_message(message_type)
  if message_type == "prompt" or message_type == "code" then
    return 0
  elseif message_type == "logo" then
    return 2
  elseif message_type == "answer" or message_type == "error" then
    return 1
  end
end

-- Take a message string, wrap it to the given `max_width` and then prefix each line.
local function prefix_message(message_type, message, max_width)
  -- We subtract five from the maximum width as we need space in each line for the prefix
  local lines = utils.wrap_text_table(message, max_width - 5, true)
  local sign = Config.options.signs[message_type]

  if message_type ~= "logo" then
    for i = 1, #lines do
      if i == 1 and sign ~= nil then
        lines[i] = " " .. sign .. " | " .. lines[i]
      else
        lines[i] = "   | " .. lines[i]
      end
    end
  end

  return lines
end

-- Work out the lengths of the message prefixes.
--
-- We need to do this (rather than just assume the value of 5), as our signs might be unicode, and VIM uses byte offsets
-- for columns rather than characters.
local function message_prefix_lengths(message)
  if message.type == "logo" then return { first = 0, rest = 0 } end

  local first = 5
  local rest = 5

  local sign = Config.options.signs[message.type]
  if sign ~= nil then
    -- If the sign is a unicode string, then we can end up with more than one byte in the first line of a message
    -- prefix, which means the highlighting will be wrong: remember that 'nvim_buf_add_highlight' uses byte-indexed
    -- column values, not _character_ indexed.
    first = vim.fn.strlen(sign) + 4
  end

  return { first = first, rest = rest }
end

-- Render a message into the buffer.
local function render_message(bufnr, message)
  -- Set the buffer as modifiable before we apply the changes
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  -- Add some blank lines if 'start_line' is out-of-bounds
  while message.start_line > vim.api.nvim_buf_line_count(bufnr) do
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "" })
  end

  -- Insert the lines for the message into the buffer
  vim.api.nvim_buf_set_lines(bufnr, message.start_line, message.start_line,
    true, message.lines)

  -- Find the highligth group for the message type and apply it (if found)
  local hl_group = Config.options.highlights[message.type]
  if hl_group ~= nil then
    -- The highlighting starts at column 0 for the logo, but all other stuff starts at column 5
    local lengths = message_prefix_lengths(message)

    for index = message.start_line, message.end_line do
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl_group, index, index ==
        message.start_line and lengths.first or
        lengths.rest, -1)
    end
  end

  -- Change the buffer back to read-only after we've applied our changes
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

local function highlight_message(bufnr, message, last_message)
  -- Set the buffer as modifiable before we apply the changes
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  -- If we have a previous highlighted message, then we want to reset it's highlighting
  if last_message ~= nil then
    vim.api.nvim_buf_clear_namespace(bufnr, highlight_ns,
      last_message.start_line,
      last_message.end_line)
  end

  -- Now highlight the current message (if we have one)
  if message ~= nil then
    local lengths = message_prefix_lengths(message)
    for index = message.start_line, message.end_line do
      vim.api.nvim_buf_add_highlight(bufnr, highlight_ns,
        Config.options.highlights.selected, index,
        0, (index == message.start_line and
            lengths.first or lengths.rest) - 1)
    end
  end

  -- Change the buffer back to read-only after we've applied our changes
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

local Log = {}
Log.__index = Log

local LAST_CONVERSATION = {}

function Log:new(bufnr, winid)
  self = setmetatable({}, Log)

  self.id = os.time()
  self.bufnr = bufnr
  self.winid = winid
  self.selected = 0
  self.messages = {}
  self.timer = nil

  -- Set the filetype of the log window to 'chatgpt'
  vim.api.nvim_buf_set_option(bufnr, "filetype", "chatgpt")

  -- Add the logo to the log
  self:add("logo", Config.options.logo)

  return self
end

function Log:save()
  local found = false
  for _, message in ipairs(self.messages) do
    if message.type ~= "logo" then found = true end
  end

  if found then LAST_CONVERSATION = { id = self.id, messages = self.messages } end
end

function Log:load()
  if LAST_CONVERSATION.id == nil then
    vim.notify("No previous conversation to load", vim.log.levels.WARN)
    return
  end

  self.id = LAST_CONVERSATION.id
  for _, message in ipairs(LAST_CONVERSATION.messages) do
    if message.type ~= "logo" then self:add(message.type, message.message) end
  end
end

function Log:buffer_exists() return vim.fn.bufexists(self.bufnr) == 1 end

function Log:get_ideal_width()
  local width = 120
  if self:buffer_exists() then width = vim.api.nvim_win_get_width(self.winid) end
  return width
end

function Log:gather_conversation()
  local conversation = {}
  for _, message in ipairs(self.messages) do
    if message.type ~= "logo" and message.type ~= "error" then
      table.insert(conversation, message.message)
    end
  end

  return table.concat(conversation, "\n")
end

function Log:get_last_message()
  if #self.messages > 0 then return self.messages[#self.messages] end
  return nil
end

function Log:get_selected_message()
  if self.selected > 0 then return self.messages[self.selected] end
  return nil
end

function Log:yank_conversation()
  local conversation = {}
  for _, message in ipairs(self.messages) do
    if message.type ~= "logo" and message.type ~= "error" then
      if message.type == "prompt" or message.type == "code" then
        table.insert(conversation, "> " .. message.message)
      else
        table.insert(conversation, message.message)
      end
    end
  end

  local text = table.concat(conversation, "\n\n")
  vim.fn.setreg("+", text)
  vim.notify("Copied ChatGPT conversation to clipboard", vim.log.levels.INFO)
end

function Log:yank_selected_message()
  local selected = self:get_selected_message()
  if selected then
    vim.fn.setreg("+", selected.message)
    vim.notify("Copied ChatGPT reply to clipboard", vim.log.levels.INFO)
  end
end

function Log:select_message(index)
  if index < 1 or index > #self.messages then
    vim.notify("Invalid message index: " .. index, vim.log.levels.ERROR)
    return
  end

  local selected = self.messages[index]
  if selected.type ~= "answer" then
    vim.notify(
      ("Attempt to select message at index %i, which has type '%s'"):format(
        index, selected.type), vim.log.levels.ERROR)
    return
  end

  local last_selected = self:get_selected_message()
  self.selected = index
  highlight_message(self.bufnr, selected, last_selected)
end

function Log:select_next_answer()
  local selected = self.selected

  if selected < #self.messages then
    selected = 1 + selected

    -- Skip selection until we get to the next answer
    while selected < #self.messages and self.messages[selected].type ~= "answer" do
      selected = 1 + selected
    end

    if selected <= #self.messages and self.messages[selected].type == "answer" then
      self:select_message(selected)
    end
  end
end

function Log:select_previous_answer()
  local selected = self.selected

  if selected > 1 then
    selected = selected - 1

    -- Skip selection until we get to the next answer
    while selected > 1 and self.messages[selected].type ~= "answer" do
      selected = selected - 1
    end

    if selected > 0 and self.messages[selected].type == "answer" then
      self:select_message(selected)
    end
  end
end

function Log:add(message_type, message_text)
  -- If we still have a timer running, then we need to stop the progress
  self:cancel_progress()

  -- Figure out the start line for this message. We're either starting at the first line in the buffer or we're going to
  -- start just after the last message. We use the 'lead_for_message' to get the leading between each message.
  local start_line = 0
  local last_message = self:get_last_message()
  if last_message ~= nil then
    start_line = last_message.end_line + lead_for_message(last_message.type)
  end

  -- Get the ideal width for our window, and then split the message into prefixed lines.
  local lines = prefix_message(message_type, message_text,
    self:get_ideal_width())

  -- Create the message table and add it to the table of messages in the log
  local message = {
    index = #self.messages + 1,
    type = message_type,
    message = message_text,
    lines = lines,
    start_line = start_line,
    end_line = start_line + #lines
  }
  table.insert(self.messages, message)

  -- Render this message into the buffer
  render_message(self.bufnr, message)

  -- Set the cursor to the end of the text, so we scroll the window
  vim.api.nvim_win_set_cursor(self.winid, { message.end_line, 0 })

  -- Set this message as the selected message if it was an answer
  if message_type == "answer" then self:select_message(#self.messages) end
end

function Log:is_busy() return self.timer ~= nil end

function Log:start_progress()
  local index = 1
  local first = true

  self.timer = vim.loop.new_timer()
  self.timer:start(0, 250, vim.schedule_wrap(function()
    local char = Config.options.progress[index]

    -- Set the buffer as modifiable before we apply the changes
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)

    -- Write the message to the buffer
    vim.api.nvim_buf_set_lines(self.bufnr, first and -1 or -2, -1, true, {
      "   " .. char .. " loading " .. string.rep(".", index - 1)
    })

    if first then
      -- Set the cursor to the end of the text, so we scroll the window
      vim.api.nvim_win_set_cursor(self.winid, {
        vim.api.nvim_buf_line_count(self.bufnr), 0
      })
      first = false
    end

    if index < 4 then
      index = 1 + index
    else
      index = 1
    end

    -- Change the buffer back to read-only after we've applied our changes
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  end))
end

function Log:cancel_progress()
  if self.timer ~= nil then
    self.timer:stop()
    self.timer = nil

    -- Erase the last line from the buffer (which is our progress line)
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.bufnr, -2, -1, true, { "" })
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  end
end

return Log
