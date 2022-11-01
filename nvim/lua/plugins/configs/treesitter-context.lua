local treesitter_context = require "treesitter-context"

local M = {}

M.setup = function() treesitter_context.setup { enabled = true } end

return M
