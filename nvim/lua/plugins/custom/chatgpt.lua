local utils = require("core.utils")
local openai = require("plugins.custom.openai_tools")
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")

local function patch_cursor_position(target_cursor, force)
  local cursor = vim.api.nvim_win_get_cursor(0)

  if target_cursor[2] == cursor[2] and force then
    -- Did not exit insert mode yet, but it's going to
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })
  elseif target_cursor[2] - 1 == cursor[2] then
    -- Already exited insert mode.
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })
  end
end

local ChatInput = Input:extend("ChatInput")

function ChatInput:init(popup_options, options)
  ChatInput.super.init(self, popup_options, options)

  self.input_props.on_submit = function(value)
    local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)
    local prompt_normal_mode = vim.fn.mode() == "n"

    vim.schedule(function()
      if prompt_normal_mode then vim.api.nvim_command("stopinsert") end

      if not self._.disable_cursor_position_patch then
        patch_cursor_position(target_cursor, prompt_normal_mode)
      end

      if options.on_submit then options.on_submit(value) end
    end)
  end
end

local Chat = {}
Chat.__index = Chat

local SIGNS = { prompt = "", answer = "ﮧ" }

local PROGRESS_CHARS = { "|", "/", "-", "\\" }

local WELCOME = [[
   ____                   ___    ____   ________          __  __________  ______
  / __ \____  ___  ____  /   |  /  _/  / ____/ /_  ____ _/ /_/ ____/ __ \/_  __/
 / / / / __ \/ _ \/ __ \/ /| |  / /   / /   / __ \/ __ `/ __/ / __/ /_/ / / /
/ /_/ / /_/ /  __/ / / / ___ |_/ /   / /___/ / / / /_/ / /_/ /_/ / ____/ / /
\____/ .___/\___/_/ /_/_/  |_/___/   \____/_/ /_/\__,_/\__/\____/_/     /_/
    /_/
]]

function Chat:new(bufnr, winid)
  self = setmetatable({}, Chat)

  self.bufnr = bufnr
  self.winid = winid
  self.selected_index = 0
  self.messages = {}
  self.timer = nil

  return self
end

function Chat:close() self:stop_timer() end

function Chat:welcome()
  local lines = utils.split_lines(WELCOME)
  local end_line = #lines

  self:set_lines(0, 0, false, lines)
  for line_num = 0, end_line do self:add_highlight("Comment", line_num, 0, -1) end
end

function Chat:is_busy() return self.timer ~= nil end

function Chat:buffer_exists() return vim.fn.bufexists(self.bufnr) == 1 end

function Chat:add(type, text)
  if not self:buffer_exists() then return end

  local width = self:get_width() - 10
  local max_width = 120
  if width > max_width then max_width = width end

  text = utils.wrap_text(text, width)

  local start_line = 0
  if self.selected_index > 0 then
    local prev = self.messages[self.selected_index]
    start_line = prev.end_line + (prev.type == "answer" and 2 or 1)
  end

  local lines = {}
  local nlines = 0

  for line in string.gmatch(text, "[^\n]+") do
    nlines = nlines + 1
    table.insert(lines, line)
  end

  table.insert(self.messages, {
    type = type,
    text = text,
    lines = lines,
    nlines = nlines,
    start_line = start_line,
    end_line = start_line + nlines - 1
  })

  self:next()
  self:render_last_message()
end

function Chat:add_prompt(text) self:add("prompt", text) end
function Chat:add_answer(text) self:add("answer", text) end

function Chat:next()
  local count = self:count()
  if self.selected_index < count then
    self.selected_index = 1 + self.selected_index
  else
    self.selected_index = 1
  end
end

function Chat:get_selected() return self.messages[self.selected_index] end

function Chat:render_last_message()
  local is_timer_set = self.timer ~= nil
  self:stop_timer()

  local message = self:get_selected()
  local lines = {}
  local i = 0

  for w in string.gmatch(message.text, "[^\r\n]+") do
    local prefix = "   | "
    if i == 0 then prefix = " " .. SIGNS[message.type] .. " | " end

    table.insert(lines, prefix .. w)
    i = i + 1
  end
  table.insert(lines, "")

  local start_index = self.selected_index == 1 and 0 or -1
  if is_timer_set then start_index = start_index - 1 end
  self:set_lines(start_index, -1, false, lines)

  if message.type == "prompt" then
    for index, _ in ipairs(lines) do
      self:add_highlight("Comment", message.start_line + index - 1, 0, -1)
    end
  end

  if self.selected_index > 2 then self:set_cursor({ message.end_line - 1, 0 }) end
end

function Chat:show_progress()
  local index = 1

  self.timer = vim.loop.new_timer()
  self.timer:start(0, 250, vim.schedule_wrap(function()
    local char = PROGRESS_CHARS[index]
    self:set_lines(-2, -1, false, {
      "   " .. char .. " loading " .. string.rep(".", index - 1)
    })
    if index < 4 then
      index = index + 1
    else
      index = 1
    end
  end))
end

function Chat:stop_timer()
  if self.timer ~= nil then
    self.timer:stop()
    self.timer = nil
  end
end

function Chat:to_string()
  local str = ""
  for _, message in pairs(self.messages) do str = str .. message.text .. "\n" end
  return str
end

function Chat:count()
  local count = 0
  for _ in pairs(self.messages) do count = 1 + count end
  return count
end

function Chat:set_lines(start_index, end_index, strict_indexing, lines)
  if self:buffer_exists() then
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.bufnr, start_index, end_index,
                               strict_indexing, lines)
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  end
end

function Chat:add_highlight(hl_group, line, col_start, col_end)
  if self:buffer_exists() then
    vim.api.nvim_buf_add_highlight(self.bufnr, -1, hl_group, line, col_start,
                                   col_end)
  end
end

function Chat:set_cursor(pos)
  if self:buffer_exists() then vim.api.nvim_win_set_cursor(self.winid, pos) end
end

function Chat:get_width()
  if self:buffer_exists() then return vim.api.nvim_win_get_width(self.winid) end
end

local M = {}

M.open_chat = function()
  local layout, chat, chat_input

  local chat_window = Popup({
    filetype = "chatgpt",
    border = {
      highlight = "FloatBorder",
      style = "rounded",
      text = { top = " ChatGPT " }
    }
  })

  local scroll_chat = function(direction)
    local speed = vim.api.nvim_win_get_height(chat_window.winid) / 2
    local input = direction > 0 and [[]] or [[]]
    local count = math.abs(speed)

    vim.api.nvim_win_call(chat_window.winid, function()
      vim.cmd([[normal! ]] .. count .. input)
    end)
  end

  chat_input = ChatInput({
    prompt = "  ",
    border = {
      highlight = "FloatBorder",
      style = "rounded",
      text = { top_align = "center", top = " Prompt " }
    },
    win_options = { winhighlight = "Normal:Normal" }
  }, {
    prompt = "  ",
    on_close = function()
      chat:close()
      layout:unmount()
    end,
    on_submit = vim.schedule_wrap(function(value)
      if chat:is_busy() then
        vim.notify("ChatGPT is busy, please wait...", vim.log.levels.WARN)
        return
      end

      vim.api.nvim_buf_set_lines(chat_input.bufnr, 0, 1, false, { "" })

      chat:add_prompt(value)
      chat:show_progress()

      openai._execute(chat:to_string(), nil, vim.schedule_wrap(function(res)
        if #res.body.choices == 0 then
          print("No response from OpenGPT")
          return
        end

        local choice = res.body.choices[1]
        chat:add_answer(choice.text)
      end))
    end)
  })

  layout = Layout({
    relative = "editor",
    position = "50%",
    size = { width = "80%", height = "80%" }
  }, Layout.Box({
    Layout.Box(chat_window, { grow = 1 }), Layout.Box(chat_input, { size = 3 })
  }, { dir = "col" }))

  chat_input:map("i", "<C-y>", function()
    local msg = chat:get_selected()
    vim.fn.setreg("+", msg.text)
    vim.notify("Copied ChatGPT reply to clipboard", vim.log.levels.INFO)
  end, { noremap = true })

  chat_input:map("i", "<C-u>", function() scroll_chat(-1) end,
                 { noremap = true, silent = true })

  chat_input:map("i", "<C-d>", function() scroll_chat(1) end,
                 { noremap = true, silent = true })

  chat_input:map("i", "<C-c>", function() chat_input.input_props.on_close() end,
                 { noremap = true, silent = true })

  layout:mount()
  chat = Chat:new(chat_window.bufnr, chat_window.winid)
  vim.api.nvim_buf_set_option(chat_window.bufnr, "filetype", "chatgpt")
  chat:welcome()
end

M.setup = function()
  vim.api.nvim_create_user_command("ChatGPT", function() M.open_chat() end, {})
end

return M
