-- https://github.com/stevearc/oil.nvim
return {
  "stevearc/oil.nvim",
  cmd = { "Oil" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    {
      "<space>-",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open parent directory in floating window"
    },
  },
  opts = {
    delete_to_trash = true,
    columns = { "icon" },
    view_options = {
      show_hidden = true,
    }
  }
}
