local Layout = require("nui.layout")
local Popup = require("nui.popup")
local openai = require("plugins.custom.openai_tools")
local Input = require("core.nui.non-dismiss-input")
local Log = require("plugins.custom.chatgpt.log")
local Config = require("plugins.custom.chatgpt.config")

local M = {}

M.open_chat = function()
  local layout, chat_input, log

  local chat_window = Popup(Config.options.chat_window)

  chat_input = Input(Config.options.chat_input, {
    prompt = Config.options.chat_input.prompt,
    on_close = function()
      log:cancel_progress()
      layout:unmount()
    end,
    on_submit = vim.schedule_wrap(function(value)
      if log:is_busy() then
        vim.notify("ChatGPT is busy, please wait...", vim.log.levels.WARN)
        return
      end

      vim.api.nvim_buf_set_lines(chat_input.bufnr, 0, 1, false, { "" })

      log:add("prompt", value)
      log:start_progress()

      openai._execute(log:gather_conversation(), nil,
                      vim.schedule_wrap(function(res)
        log:cancel_progress()

        if #res.body.choices == 0 then
          vim.notify("No response from ChatGPT", vim.log.levels.WARN)
          log:add("answer", "No response from ChatGPT")
          return
        end

        local choice = res.body.choices[1].text
        choice = string.gsub(choice, "^%s*(.-)", "%1")
        log:add("answer", choice)
      end))
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
end

M.setup = function(options)
  Config.setup(options)

  vim.api.nvim_set_hl(0, "ChatGPTLogo", { fg = "#bb9af7" })
  vim.api.nvim_set_hl(0, "ChatGPTPrompt", { fg = "#7079a5" })
  vim.api.nvim_set_hl(0, "ChatGPTAnswer", { fg = "#c0caf5" })
  vim.api.nvim_set_hl(0, "ChatGPTSelected", { fg = "#2ac3de", bg = "#0f5561" })

  vim.api.nvim_create_user_command("ChatGPT", function() M.open_chat() end, {})
end

return M
