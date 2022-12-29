-- Floating statuslines for Neovim
-- https://github.com/b0o/incline.nvim

local M = {
  "b0o/incline.nvim",
  event = "BufReadPre",
}

local function get_diagnostic_label(props)
  local icons = { error = '', warn = '', info = '', hint = '', }
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(label, { icon .. ' ' .. n .. ' ', group = 'DiagnosticSign' .. severity })
    end
  end
  if #label > 0 then
    table.insert(label, { '│ ' })
  end
  return label
end

local function get_git_diff(props)
  local icons = { removed = "", changed = "", added = "" }
  local labels = {}
  local signs = vim.api.nvim_buf_get_var(props.buf, "gitsigns_status_dict")

  for name, icon in pairs(icons) do
    if tonumber(signs[name]) and signs[name] > 0 then
      table.insert(labels, { icon .. " " .. signs[name] .. " ",
        group = "Diff" .. name
      })
    end
  end
  if #labels > 0 then
    table.insert(labels, { '│ ' })
  end
  return labels
end

function M.config()
  if vim.g.started_by_firenvim then
    return
  end

  local colors = require("tokyonight.colors").setup()
  local fg = "#394264"

  require("incline").setup({
    highlight = {
      groups = {
        InclineNormal = {
          guifg = colors.fg,
          guibg = fg,
          -- gui = "bold",
        },
        InclineNormalNC = {
          guifg = fg,
          guibg = colors.black,
        },
      },
    },
    window = {
      margin = {
        vertical = 0,
        horizontal = 1,
      },
    },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      local icon, color = require("nvim-web-devicons").get_icon_color(filename)
      local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and "italic" or ""

      return {
        { get_diagnostic_label(props) },
        { get_git_diff(props) },
        { icon, guifg = color },
        { " " },
        { filename, gui = modified },
      }
    end,
  })
end

return M
