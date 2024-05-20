return {
  "NeogitOrg/neogit",
  branch = "master",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim"
  },
  config = true,
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
