-- Quickfix enhancements
-- https://github.com/stevearc/quicker.nvim
return {
  'stevearc/quicker.nvim',
  event = "FileType qf",
  keys = {
    {
      "<Leader>qf",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle quickfix"
    },
    {
      "<Leader>ql",
      function()
        require("quicker").toggle({ loclist = true })
      end,
      desc = "Toggle loclist"
    },
  },
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    keys = {
      {
        "<Leader>qe",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<Leader>qc",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
      {
        "<Leader>qr",
        function()
          require("quicker").refresh()
        end,
        desc = "Refresh quickfix"
      }
    }
  },
}
