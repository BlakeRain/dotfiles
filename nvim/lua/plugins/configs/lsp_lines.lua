local lsp_lines = require("lsp_lines")

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({ virtual_text = false })

local M = {}
M.setup = function() lsp_lines.setup({}) end

return M

