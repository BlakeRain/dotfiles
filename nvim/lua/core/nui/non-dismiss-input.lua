-- Most of this code is taken from 'nui.input', but modified to stop the input dismissing when we
-- press <CR>. We also set 'textwidth' to zero so we don't end up with only the last bit of a
-- wrapped input.
local Popup = require("nui.popup")
local Text = require("nui.text")
local defaults = require("nui.utils").defaults
local is_type = require("nui.utils").is_type
local event = require("nui.utils.autocmd").event

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

local ChatInput = Popup:extend("ChatInput")

function ChatInput:init(popup_options, options)
  popup_options.enter = true
  popup_options.buf_options = defaults(popup_options.buf_options, {})
  popup_options.buf_options.buftype = "prompt"

  if not is_type("table", popup_options.size) then
    popup_options.size = {
      width = popup_options.size
    }
  end

  popup_options.size.height = 1
  ChatInput.super.init(self, popup_options)

  self._.default_value = defaults(options.default_value, "")
  self._.prompt = Text(defaults(options.prompt, ""))
  self._.disable_cursor_position_patch = defaults(options.disable_cursor_position_patch, false)

  self.input_props = {}
  self._.on_change = options.on_change
  self._.on_close = options.on_close or function() end
  self._.on_submit = options.on_submit or function() end
end

function ChatInput:mount()
  local props = self.input_props

  if self._.mounted then
    return
  end

  ChatInput.super.mount(self)

  if self._.on_change then
    props.on_change = function()
      local value_with_prompt = vim.api.nvim_buf_get_lines(self.bufnr, 0, 1, false)[1]
      local value = string.sub(value_with_prompt, self._.prompt:length() + 1)
      self._.on_change(value)
    end

    vim.api.nvim_buf_attach(self.bufnr, false, {
      on_lines = props.on_change
    })
  end

  if #self._.default_value then
    self:on(event.InsertEnter, function()
      vim.api.nvim_feedkeys(self._.default_value, "t", true)
    end, { once = true })
  end

  vim.fn.prompt_setprompt(self.bufnr, self._.prompt:content())
  if self._.prompt:length() > 0 then
    vim.schedule(function()
      self._.prompt:highlight(self.bufnr, self.ns_id, 1, 0)
    end)
  end

  props.on_submit = function(value)
    self._.pending_submit_value = value
    self._.on_submit(value)
    -- self:unmount()
  end

  vim.fn.prompt_setcallback(self.bufnr, props.on_submit)

  props.on_close = function()
    self:unmount()
  end

  vim.fn.prompt_setinterrupt(self.bufnr, props.on_close)
  vim.api.nvim_command("startinsert!")
end

function ChatInput:unmount()
  if not self._.mounted then
    return
  end

  local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)
  local prompt_mode = vim.fn.mode()

  ChatInput.super.unmount(self)
  if self._.loading then
    return
  end

  self._.loading = true
  local pending_submit_value = self._.pending_submit_value

  vim.schedule(function()
    -- NOTE: on prompt-buffer normal mode <CR> causes neovim to enter insert mode.
    --  ref: https://github.com/neovim/neovim/blob/d8f5f4d09078/src/nvim/normal.c#L5327-L5333
    if (pending_submit_value and prompt_mode == "n") or prompt_mode == "i" then
      vim.api.nvim_command("stopinsert")
    end

    if not self._.disable_cursor_position_patch then
      patch_cursor_position(target_cursor, pending_submit_value and prompt_mode == "n")
    end

    if pending_submit_value then
      self._.pending_submit_value = nil
    else
      self._.on_close()
    end
    self._.loading = false
  end)
end

return ChatInput
