local LOGO = [[
   ____                   ___    ____   ________          __  __________  ______
  / __ \____  ___  ____  /   |  /  _/  / ____/ /_  ____ _/ /_/ ____/ __ \/_  __/
 / / / / __ \/ _ \/ __ \/ /| |  / /   / /   / __ \/ __ `/ __/ / __/ /_/ / / /
/ /_/ / /_/ /  __/ / / / ___ |_/ /   / /___/ / / / /_/ / /_/ /_/ / ____/ / /
\____/ .___/\___/_/ /_/_/  |_/___/   \____/_/ /_/\__,_/\__/\____/_/     /_/
    /_/

Not actually ChatGPT, but preserve the conversation with GPT-3
]]

local M = {}

function M.defaults()
  local defaults = {
    logo = LOGO,
    signs = { prompt = "", answer = "ﮧ", code = "" },
    progress = { "|", "/", "-", "\\" },
    highlights = {
      prompt = "ChatGPTPrompt",
      code = "ChatGPTPrompt",
      logo = "ChatGPTLogo",
      answer = "ChatGPTAnswer",
      selected = "ChatGPTSelected"
    },
    chat_window = {
      filetype = "chatgpt",
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = { top = " ChatGPT " }
      }
    },
    chat_input = {
      prompt = "> ",
      size = { height = 4 },
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = { top_align = "center", top = " Prompt " }
      },
      win_options = { winhighlight = "Normal:Normal" }
    },
    layout = {
      relative = "editor",
      position = "50%",
      size = { width = "80%", height = "80%" }

    }
  }

  return defaults
end

M.options = {}

function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", M.defaults(), options)
end

return M
