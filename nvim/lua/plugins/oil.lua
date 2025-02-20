-- https://github.com/stevearc/oil.nvim
return {
  "stevearc/oil.nvim",
  cmd = { "Oil" },
  lazy = false,
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
    default_file_explorer = true,
    delete_to_trash = true,
    columns = { "icon" },
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["q"] = { "actions.close", mode = "n" },
      ["gp"] = function()
        require("image_preview").PreviewImageOil()
      end
    }
  }
}
