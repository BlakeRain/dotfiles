-- Goto preview window
-- https://github.com/rmagatti/goto-preview
--
local M = {
  'rmagatti/goto-preview',
  dependencies = { "rmagatti/logger.nvim" },
  config = true,
  event = { "BufRead", "BufNewFile" },
  keys = {
    { "gpd", function() require("goto-preview").goto_preview_definition() end,     desc = "Preview definition" },
    { "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview implementation" },
    { "gpr", function() require("goto-preview").goto_preview_references() end,     desc = "Preview references" },
    { "gP",  function() require("goto-preview").close_all_win() end,               desc = "Close preview windows" },
  }
}

return M
