-- https://github.com/sphamba/smear-cursor.nvim
return {
  "sphamba/smear-cursor.nvim",
  -- event = "VeryLazy",
  keys = {
    { "<leader>ES", function() require("smear_cursor").toggle() end, desc = "Toggle smear cursor" }
  },
  opts = {
    cursor_color = "#F9DFDB",
    smear_between_neighbor_lines = true,
    stiffness = 0.8,
    trailing_stiffness = 0.5,
    distance_stop_animation = 0.5,
    hide_target_hack = false,
    -- legacy_computing_symbols_support = true,
    -- transparent_bg_fallback_color =
  }
}
