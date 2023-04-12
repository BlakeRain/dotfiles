-- A lua powered greeter like vim-startify / dashboard-nvim
-- https://github.com/goolord/alpha-nvim

local LOGO = [[
  ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆
   ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦
         ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄
          ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄
         ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀
  ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄
 ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄
⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄
⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄
     ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆
      ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃
]]

local function create_dashboard()
  local dashboard = require("alpha.themes.dashboard")

  local function button(key, label, info)
    local widget = dashboard.button(key, label, info)
    widget.opts.hl = "AlphaButtons"
    widget.opts.hl_shortcut = "AlphaShortcut"
    return widget
  end

  local header = {
    type = "text",
    val = vim.split(LOGO, "\n"),
    opts = {
      position = "center",
      hl = "AlphaHeader"
    }
  }

  local buttons = {
    type = "group",
    val = {
      button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
      button("f", " " .. " Find file", ":Telescope find_files <CR>"),
      button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
      button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
      button("m", " " .. " Bookmarks", ":Telescope marks <CR>"),
      button("q", " " .. " Quit", ":qa<CR>"),
    },
    opts = {
      spacing = 1,
      hl = "AlphaButtons"
    }
  }

  local footer = {
    type = "text",
    val = "",
    opts = {
      position = "center",
      hl = "Type"
    }
  }

  local section = {
    header = header,
    buttons = buttons,
    footer = footer,
  }

  return {
    section = section,
    layout = {
      { type = "padding", val = 8 },
      section.header,
      { type = "padding", val = 2 },
      section.buttons,
      section.footer
    },
    opts = {
      margin = 5
    }
  }
end

local M = {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    local dashboard = create_dashboard()
    require("alpha").setup(dashboard)

    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}

return M
