-- Goto preview window
-- https://github.com/rmagatti/goto-preview
--
local M = {
  'rmagatti/goto-preview',
  config = true,
  event = { "BufRead", "BufNewFile" },
  keys = {
    { "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Preview Definition" },
    { "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview Implementation" },
    { "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Preview References" },
    { "gP", function() require("goto-preview").close_all_win() end, desc = "Close Preview Windows" },
  }
}

return M
