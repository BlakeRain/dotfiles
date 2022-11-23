local lualine = require("lualine")
local gps = require("nvim-gps")

local function lualine_winnum()
  return "w" ..
           vim.inspect(
             vim.api.nvim_win_get_number(vim.api.nvim_get_current_win()))
end

local function neo_tree_lualine_cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end

local neo_tree_lualine = {
  sections = { lualine_a = { neo_tree_lualine_cwd } },
  filetypes = { "neo-tree" }
}

local M = {}
M.setup = function()
  gps.setup()

  lualine.setup({
    extensions = { neo_tree_lualine },
    options = {
      icons_enabled = true,
      theme = "tokyonight",
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = true
      -- disabled_filetypes = { "neo-tree" }
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } }
      },
      lualine_c = {
        { "filename", path = 1 }, {
          function() return "Autorun[make]" end,
          cond = function() return vim.b.__automake == true end
        }, { gps.get_location, cond = gps.is_available }
      },
      lualine_x = { lualine_winnum, "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { lualine_winnum, "location" },
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {}
  })
end

return M
