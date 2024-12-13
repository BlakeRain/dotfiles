return {
  {
    "aaronik/treewalker.nvim",
    opts = {
      highlight = true
    },
    keys = {
      { "<C-j>", function() require("treewalker").move_down() end, desc = "Treewalker down" },
      { "<C-k>", function() require("treewalker").move_up() end,   desc = "Treewalker up" },
      { "<C-h>", function() require("treewalker").move_out() end,  desc = "Treewalker out" },
      { "<C-l>", function() require("treewalker").move_in() end,   desc = "Treewalker in" },
    }
  }
}
