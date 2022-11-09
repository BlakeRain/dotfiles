local surround = require("nvim-surround")
local config = require("nvim-surround.config")

local M = {}

M.setup = function()
  surround.setup {
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
