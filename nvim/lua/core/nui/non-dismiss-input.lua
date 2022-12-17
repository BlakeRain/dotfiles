-- Most of this code is taken from 'nui.input', but modified to stop the input dismissing when we press <CR>.
-- We also set 'textwidth' to zero so we don't end up with only the last bit of a wrapped input.
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
  vim.api.nvim_buf_set_option(self.bufnr, "textwidth", 0)

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

return ChatInput
