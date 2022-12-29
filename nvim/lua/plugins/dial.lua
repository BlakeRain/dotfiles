-- Dial plugin for number increment/decrement
-- https://github.com/monaqa/dial.nvim

local M = {
  "monaqa/dial.nvim",
  keys = {
    {
      "<C-a>",
      function()
        return require("dial.map").inc_normal()
      end,
      expr = true,
    },
    {
      "<C-a>",
      function()
        return require("dial.map").inc_visual()
      end,
      expr = true,
      mode = "v"
    },
    {
      "g<C-a>",
      function()
        return require("dial.map").inc_gvisual()
      end,
      expr = true,
      mode = "v"
    },

    {
      "<C-x>",
      function()
        return require("dial.map").dec_normal()
      end,
      expr = true,
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_visual()
      end,
      expr = true,
      mode = "v",
    },
    {
      "g<C-x>",
      function()
        return require("dial.map").dec_gvisual()
      end,
      expr = true,
      mode = "v",
    },
  },
}

function M.config()
  local dial_augend = require("dial.augend")
  local dial_config = require("dial.config")

  dial_config.augends:register_group{
    default = {
      dial_augend.integer.alias.decimal_int, -- non-negative decimal number (0, 1, 2, 3, ...)
      dial_augend.integer.alias.hex,         -- non-negative hexadecimal number (0x01, 0x1a1f, etc.)
      dial_augend.integer.alias.binary,      -- non-negative binary number (0b0101, 0b11001111, etc.)
      dial_augend.date.alias["%Y/%m/%d"],
      dial_augend.date.alias["%Y-%m-%d"],
      dial_augend.date.alias["%H:%M"],
      dial_augend.constant.alias.bool,
      dial_augend.constant.alias.alpha,
      dial_augend.constant.alias.alpha,
      dial_augend.semver.alias.semver,
      dial_augend.constant.new{
        elements = {"true", "false"},
        word = true,
        cyclic = true,
      },
      dial_augend.constant.new{
        elements = {"encode", "decode"},
        word = false,
        cyclic = true
      }
    }
  }
end

return M
