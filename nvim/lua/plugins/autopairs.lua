-- Autopairs
-- https://github.com/windwp/nvim-autopairs

local M = {
  'windwp/nvim-autopairs',
  dependencies = { 'hrsh7th/nvim-cmp' },
  event = "InsertEnter",
}

function M.config()
  local autopairs = require("nvim-autopairs")
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")

  autopairs.setup({
    check_ts = true,
    fast_wrap = {},
  })

  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
end

return M
