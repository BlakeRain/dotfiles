return {
  "WilliamHsieh/overlook.nvim",
  opts = {},

  -- Optional: set up common keybindings
  keys = {
    { "<leader>pd", function() require("overlook.api").peek_definition() end, desc = "Overlook: Peek definition" },
    { "<leader>pc", function() require("overlook.api").close_all() end, desc = "Overlook: Close all popup" },
    { "<leader>ps", function() require("overlook.api").open_in_split() end, desc = "Overlook: Open popup in split" },
    { "<leader>pv", function() require("overlook.api").open_in_vsplit() end, desc = "Overlook: Open popup in vsplit" },
    { "<leader>pt", function() require("overlook.api").open_in_tab() end, desc = "Overlook: Open popup in tab" },
    { "<leader>po", function() require("overlook.api").open_in_original_window() end, desc = "Overlook: Open popup in current window" },
    { "<leader>pu", function() require("overlook.api").restore_popup() end, desc = "Overlook: Restore popup" },
  },
}
