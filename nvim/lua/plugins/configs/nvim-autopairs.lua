local autopairs = require("nvim-autopairs")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")

local M = {}
M.setup = function()
  autopairs.setup({
    check_ts = true,
    fast_wrap = {},
  })

  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
end

return M
