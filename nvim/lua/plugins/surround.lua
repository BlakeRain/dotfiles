-- Surround things (e.g. cs'' to replace ' with '; or ysw] to enclose word in []
-- https://github.com/kylechui/nvim-surround
local M = {
  'kylechui/nvim-surround',
  event = "VeryLazy",
  version = "^3.0.0"
}

function M.config()
  local surround = require("nvim-surround")
  local config = require("nvim-surround.config")

  surround.setup {
    keymaps = {
      insert = "<C-g>s",
      insert_line = "<C-g>S",
      normal = "ys",
      normal_cur = "yss",
      normal_line = "yS",
      normal_cur_line = "ySS",
      visual = "S",
      visual_line = "gS",
      delete = "ds",
      change = "cs",
      change_line = "cS",
    },
    surrounds = {
      ['g'] = {
        add = function()
          local ok, type_name = pcall(vim.fn.input, {
            prompt = "Enter generic type name: ",
            cancelreturn = vim.NIL
          })
          if ok and type_name ~= vim.NIL then
            return { { type_name .. '<' }, { '>' } }
          end
        end,
        find = function()
          return config.get_selection({ pattern = "[^=%s<>]+%b<>" })
        end,
        delete = "^(.-<)().-(>)()$",
        change = {
          target = "^.-([%w_]+)()<.->()()$",
          replacement = function()
            local ok, type_name = pcall(vim.fn.input, {
              prompt = "Enter new generic type name: ",
              cancelreturn = vim.NIL
            })

            if ok and type_name ~= vim.NIL then
              return { { type_name }, { '' } }
            end
          end
        }
      }
    }
  }
end

return M
