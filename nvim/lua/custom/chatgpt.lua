local notify = require("notify")
local utils = require("core.utils")
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local openai = require("custom.openai_tools")
local Input = require("core.nui.non-dismiss-input")
local Log = require("custom.chatgpt.log")
local Config = require("custom.chatgpt.config")

local M = {}

M.open_chat = function(args)
  args = args or {}
  local layout, chat_input, log

  local function process(prompt)
    if log:is_busy() then
      vim.notify("ChatGPT is busy, please wait...", vim.log.levels.WARN)
      return false
    end

    log:add("prompt", prompt)
    log:start_progress()

    openai._execute(log:gather_conversation(), nil,
      vim.schedule_wrap(function(res)
        log:cancel_progress()

        notify(
          ("Response received from OpenAI\n\nUsed %i tokens"):format(res.body
            .usage
            .total_tokens),
          vim.log.levels.INFO, { title = "ChatGPT" })

        if #res.body.choices == 0 then
          vim.notify("No response from ChatGPT", vim.log.levels.WARN)
          log:add("answer", "No response from ChatGPT")
          return
        end

        local choice = res.body.choices[1].text
        choice = string.gsub(choice, "^%s*(.-)", "%1")
        log:add("answer", choice)
      end))

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
  if args.restore then log:load() end
  if args.code then log:add("code", args.code) end
  if args.prompt then process(args.prompt) end
end

M.setup = function(options)
  Config.setup(options)

  vim.api.nvim_set_hl(0, "ChatGPTLogo", { fg = "#bb9af7" })
  vim.api.nvim_set_hl(0, "ChatGPTPrompt", { fg = "#7079a5" })
  vim.api.nvim_set_hl(0, "ChatGPTAnswer", { fg = "#c0caf5" })
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
