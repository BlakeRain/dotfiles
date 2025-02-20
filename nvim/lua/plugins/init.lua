return {
  -- Asynchronous co-routines for neovim
  -- https://github.com/nvim-lua/plenary.nvim
  { "nvim-lua/plenary.nvim" },

  -- UI component library
  -- https://github.com/MunifTanjim/nui.nvim
  { "MunifTanjim/nui.nvim", lazy = false },

  {
    -- Nice icons
    -- https://github.com/nvim-tree/nvim-web-devicons
    "nvim-tree/nvim-web-devicons",
    opts = { default = true }
  },


  -- Maximize and restore a window
  -- https://github.com/szw/vim-maximizer
  { "szw/vim-maximizer", cmd = "MaximizerToggle" }
}
