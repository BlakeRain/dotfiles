-- A Neovim bufferline
-- https://github.com/willothy/nvim-cokeline

local M = {
  "willothy/nvim-cokeline",
  event = "BufAdd",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local cokeline = require("cokeline")

    local get_hex = require('cokeline/utils').get_hex
    local mappings = require('cokeline/mappings')

    local comments_fg = get_hex('Comment', 'fg')
    local errors_fg = get_hex('DiagnosticError', 'fg')
    local warnings_fg = get_hex('DiagnosticWarn', 'fg')
    local red = vim.g.terminal_color_1
    local yellow = vim.g.terminal_color_3

    local components = {
      space = {
        text = ' ',
        truncation = { priority = 1 }
      },
      two_spaces = {
        text = '  ',
        truncation = { priority = 1 },
      },
      separator = {
        text = function(buffer)
          return buffer.index ~= 1 and '▏' or ''
        end,
        truncation = { priority = 1 }
      },
      devicon = {
        text = function(buffer)
          return
              (mappings.is_picking_focus() or mappings.is_picking_close())
              and buffer.pick_letter .. ' '
              or buffer.devicon.icon
        end,
        fg = function(buffer)
          return
              (mappings.is_picking_focus() and yellow)
              or (mappings.is_picking_close() and red)
              or buffer.devicon.color
        end,
        style = function(_)
          return
              (mappings.is_picking_focus() or mappings.is_picking_close())
              and 'italic,bold'
              or nil
        end,
        truncation = { priority = 1 }
      },
      index = {
        text = function(buffer)
          return buffer.index .. ': '
        end,
        truncation = { priority = 1 }
      },
      unique_prefix = {
        text = function(buffer)
          return buffer.unique_prefix
        end,
        fg = comments_fg,
        style = 'italic',
        truncation = {
          priority = 3,
          direction = 'left',
        },
      },
      filename = {
        text = function(buffer)
          return buffer.filename
        end,
        style = function(buffer)
          return
              ((buffer.is_focused and buffer.diagnostics.errors ~= 0)
                and 'bold,underline')
              or (buffer.is_focused and 'bold')
              or (buffer.diagnostics.errors ~= 0 and 'underline')
              or nil
        end,
        truncation = {
          priority = 2,
          direction = 'left',
        },
      },
      diagnostics = {
        text = function(buffer)
          return
              (buffer.diagnostics.errors ~= 0 and '  ' .. buffer.diagnostics.errors)
              or (buffer.diagnostics.warnings ~= 0 and '  ' .. buffer.diagnostics.warnings)
              or ''
        end,
        fg = function(buffer)
          return
              (buffer.diagnostics.errors ~= 0 and errors_fg)
              or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
              or nil
        end,
        truncation = { priority = 1 },
      },
      close_or_unsaved = {
        text = function(buffer)
          return buffer.is_modified and '●' or ''
        end,
        delete_buffer_on_left_click = true,
        truncation = { priority = 1 },
      },
    }

    cokeline.setup({
      show_if_buffers_are_at_least = 1,
      buffers = {
        new_buffers_position = "next",
      },
      render = {
        max_buffer_width = 30,
      },
      default_hl = {
        fg = function(buffer)
          if buffer.is_focused then
            return get_hex("Normal", "fg")
          else
            return get_hex("Comment", "fg")
          end
        end,
        -- bg = get_hex("ColorColumn", "bg"),
        bg = function(buffer)
          if buffer.is_focused then
            return get_hex("Normal", "bg")
          else
            return get_hex("ColorColumn", "bg")
          end
        end
      },
      components = {
        components.space,
        components.separator,
        components.space,
        components.devicon,
        components.space,
        components.index,
        components.unique_prefix,
        components.filename,
        components.diagnostics,
        components.two_spaces,
        components.close_or_unsaved,
        components.space
      }
    })
  end,

  keys = {
    -- Move to previous or next buffer
    { "<A-,>", "<Plug>(cokeline-focus-prev)" },
    { "<A-.>", "<Plug>(cokeline-focus-next)" },

    -- Re-order current buffer
    { "<A-<>", "<Plug>(cokeline-switch-prev)" },
    { "<A->>", "<Plug>(cokeline-switch-next)" },

    -- Close buffer
    { "<A-c>", function()
      local buf = require("cokeline.buffers").get_current()
      require("core.utils.buffers").delete(buf.number)
    end },

    -- Magic buffer-picking mode
    { "<C-s>",      "<Plug>(cokeline-pick-focus)" },
    { "<leader>bb", "<Plug>(cokeline-pick-focus)", desc = "Pick buffer" },
    {
      "<leader>bc",
      function()
        local buf = require("cokeline.buffers").get_current()
        require("core.utils.buffers").delete(buf.number)
      end,
      desc = "Close buffer"
    },
    {
      "<leader>bC",
      function()
        local buf = require("cokeline.buffers").get_current()
        require("core.utils.buffers").delete(buf.number, true)
      end,
      desc = "Close buffer (force)"
    },
  }
}

for i = 1, 9 do
  table.insert(M.keys, {
    ("<A-%d>"):format(i),
    ("<Plug>(cokeline-focus-%d)"):format(i)
  })
end

return M
