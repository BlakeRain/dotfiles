-- Status line using LUA functions
-- https://github.com/nvim-lualine/lualine.nvim
-- https://github.com/SmiteshP/nvim-gps
local M = {
  'nvim-lualine/lualine.nvim',
  event = "VeryLazy",
}

local function lualine_winnum()
  return "w" .. vim.inspect(vim.api.nvim_win_get_number(vim.api.nvim_get_current_win()))
end

local function lualine_neotree_cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

local neo_tree_lualine = {
  sections = { lualine_a = { lualine_neotree_cwd } },
  filetypes = { "neo-tree" }
}



function M.config()
  local lualine = require("lualine")
  local navic = require("nvim-navic")

  lualine.setup({
    extensions = { neo_tree_lualine },
    options = {
      icons_enabled = true,
      -- theme = "tokyonight",
      theme = "catppuccin",
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } }
      },
      lualine_c = {
        { "filename",                                 path = 1 },
        {
          function() return "Autorun[make]" end,
          cond = function() return vim.b.__automake == true end
        },
        { function() return navic.get_location() end, cond = function() return navic.is_available() end }
      },
      lualine_x = { lualine_winnum, "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { lualine_winnum, "location" },
      lualine_y = {},
      lualine_z = {}
    }
  })
end

return M
