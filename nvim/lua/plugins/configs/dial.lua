local dial_augend = require("dial.augend")
local dial_config = require("dial.config")
local utils = require("core.utils")

local M = {}
M.setup = function()
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

  utils.map("n", "<c-a>", require("dial.map").inc_normal(), { noremap = false })
  utils.map("n", "<c-x>", require("dial.map").dec_normal(), { noremap = false })
  utils.map("v", "<c-a>", require("dial.map").inc_visual(), { noremap = false })
  utils.map("v", "<c-x>", require("dial.map").dec_visual(), { noremap = false })
  utils.map("v", "g<c-a>", require("dial.map").inc_gvisual(), { noremap = false })
  utils.map("v", "g<c-x>", require("dial.map").dec_gvisual(), { noremap = false })
end

return M
