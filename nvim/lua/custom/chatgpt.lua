local utils = require("core.utils")
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local openai = require("custom.openai_tools")
local Input = require("core.nui.non-dismiss-input")
local Log = require("custom.chatgpt.log")
local Config = require("custom.chatgpt.config")

local M = {}

local KNOWN_PARAMETERS = {
  ["temperature"] = "temperature",
  ["temp"] = "temperature",
  ["t"] = "temperature",
  ["max_tokens"] = "max_tokens",
  ["max"] = "max_tokens",
  ["top_p"] = "top_p",
  ["top"] = "top_p",
  ["tp"] = "top_p",
  ["frequency_penalty"] = "frequency_penalty",
  ["freq"] = "frequency_penalty",
  ["presence_penalty"] = "presence_penalty",
  ["pres"] = "presence_penalty"
}

local function parse_parameters(message)
  local result = { message = message, parameters = {} }

  -- See if we have any prefixes in the message. These prefixes are written as attributes in the form 'x:y', where
  -- 'x' is a variable we pass as an option to GPT, and 'y' is the value of the variable 'x'.
  local prefixes = {}
  for prefix in message:gmatch("%b{}") do
    local key, value = prefix:match("{(%w+):([%w._]+)}")
    if key and value then
      value = tonumber(value)
      if not value then
        vim.notify("Invalid value for parameter '" .. key .. "'; expected a number", vim.log.levels.ERROR)
      else
        local known_key = KNOWN_PARAMETERS[key]
        if not known_key then
          vim.notify("Unknown parameter '" .. key .. "' might be ignored", vim.log.levels.WARN)
          prefixes[key] = value
        else
          prefixes[known_key] = value
        end
      end
    end
  end

  -- Remove the prefixes from the message.
  result.message = message:gsub("%b{}", "")

  -- Add the prefixes to the result.
  for key, value in pairs(prefixes) do
    result.parameters[key] = value
  end

  return result
end

M.open_chat = function(args)
  args = args or {}
  local layout, chat_input, log

  local function process(prompt)
    if log:is_busy() then
      vim.notify("ChatGPT is busy, please wait...", vim.log.levels.WARN)
      return false
    end

    local parsed = parse_parameters(prompt)

    openai.log_message(("chat %i: prompt '%s' (parameters: %s)"):format(log.id, parsed.message,
      vim.inspect(parsed.parameters)))

    log:add("prompt", parsed.message)
    log:start_progress()

    openai._execute(log:gather_conversation(),
      vim.schedule_wrap(function(res)
        log:cancel_progress()

        openai.log_message(("chat %i: [%i] %s"):format(log.id, res.status, vim.inspect(res.body)))
        if res.status ~= 200 then
          vim.notify(("Error received from OpenAI (%s):\n\n%s"):format(res.body.error.type, res.body.error.message),
            vim.log.levels.ERROR)
          log:add("error", res.body.error.message)
          return
        end

        if res.body.usage then
          vim.notify(
            ("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
              .usage
              .total_tokens),
            vim.log.levels.INFO, { title = "ChatGPT" })
        end

        if #res.body.choices == 0 then
          vim.notify("No response from ChatGPT", vim.log.levels.WARN)
          log:add("answer", "No response from ChatGPT")
          return
        end

        local choice = res.body.choices[1].message.content
        choice = string.gsub(choice, "^%s*(.-)", "%1")
        if #choice == 0 then
          vim.notify("Empty response from ChatGPT", vim.log.levels.WARN)
          log:add("answer", "Empty response from ChatGPT")
          return
        end

        log:add("answer", choice)
      end), parsed.parameters)

    return true
  end

  local chat_window = Popup(Config.options.chat_window)

  chat_input = Input(Config.options.chat_input, {
    prompt = Config.options.chat_input.prompt,
    on_close = function()
      log:cancel_progress()
      log:save()
      layout:unmount()
    end,
    on_submit = vim.schedule_wrap(function(value)
      if process(value) then
        vim.api.nvim_buf_set_lines(chat_input.bufnr, 0, 1, false, { "" })
      end
    end)
  })

  layout = Layout(Config.options.layout, Layout.Box({
    Layout.Box(chat_window, { grow = 1 }), Layout.Box(chat_input, { size = 3 })
  }, { dir = "col" }))

  chat_input:map("i", "<C-y>", function() log:yank_selected_message() end,
    { noremap = true })

  chat_input:map("i", "<C-w>", function() log:yank_conversation() end,
    { noremap = true })

  chat_input:map("i", "<C-u>", function() log:select_previous_answer() end,
    { noremap = true, silent = true })

  chat_input:map("i", "<C-d>", function() log:select_next_answer() end,
    { noremap = true, silent = true })

  layout:mount()

  log = Log:new(chat_window.bufnr, chat_window.winid)
  openai.log_message(("ChatGPT conversation %i started at %s"):format(log.id, os.date("%c")))

  if args.restore then log:load() end
  if args.code then log:add("code", args.code) end
  if args.prompt then process(args.prompt) end
end

M.setup = function(options)
  Config.setup(options)

  vim.api.nvim_set_hl(0, "ChatGPTLogo", { fg = "#bb9af7" })
  vim.api.nvim_set_hl(0, "ChatGPTPrompt", { fg = "#7079a5" })
  vim.api.nvim_set_hl(0, "ChatGPTAnswer", { fg = "#c0caf5" })
  vim.api.nvim_set_hl(0, "ChatGPTError", { fg = "#e12626" })
  vim.api.nvim_set_hl(0, "ChatGPTSelected", { fg = "#2ac3de", bg = "#0f5561" })

  vim.api.nvim_create_user_command("ChatGPT", function(args)
    args = args or {}
    local restore = args.bang == true
    local prompt = nil
    if args.range > 0 then
      local bufnr = vim.api.nvim_get_current_buf()
      local selection = utils.get_selection(bufnr)
      prompt = table.concat(selection.lines, "\n")
    end
    M.open_chat({ restore = restore, prompt = prompt })
  end, { bang = true, range = true })

  vim.api.nvim_create_user_command("ChatGPTAppend", function(args)
    args = args or {}
    local restore = args.bang == true
    local code = nil
    if args.range > 0 then
      local bufnr = vim.api.nvim_get_current_buf()
      local selection = utils.get_selection(bufnr)
      code = table.concat(selection.lines, "\n")
    end
    M.open_chat({ restore = restore, code = code })
  end, { bang = true, range = true })
end

return M
