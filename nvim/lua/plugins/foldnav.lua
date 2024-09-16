return {
  "domharries/foldnav.nvim",
  version = "*",
  config = function()
    vim.g.foldnav = {
      flash = {
        enabled = true,
      },
    }
  end,
  keys = {
    -- { "<C-h>", function() require("foldnav").goto_start() end },
    -- { "<C-j>", function() require("foldnav").goto_next() end },
    -- { "<C-k>", function() require("foldnav").goto_prev_start() end },
    -- { "<C-k>", function() require("foldnav").goto_prev_end() end },
    -- { "<C-l>", function() require("foldnav").goto_end() end },
  },
}
