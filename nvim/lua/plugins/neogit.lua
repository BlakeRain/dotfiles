return {
  "NeogitOrg/neogit",
  branch = "master",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim"
  },
  config = true,
  opts = {
    integrations = {
      diffview = true,
      snacks = true
    },
  },
  keys = {
    {
      "<leader>gg",
      function()
        require("neogit").open()
      end,
      desc = "Open NeoGit"
    }
  }
}
