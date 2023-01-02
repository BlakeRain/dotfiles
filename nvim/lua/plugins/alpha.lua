-- A lua powered greeter like vim-startify / dashboard-nvim
-- https://github.com/goolord/alpha-nvim

local M = {
  "goolord/alpha-nvim",
  event = "VimEnter"
}

local function button(sc, txt, keybind)
  local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

  local opts = {
    position = "center",
    text = txt,
    shortcut = sc,
    cursor = 5,
    width = 36,
    align_shortcut = "right",
    hl = "AlphaButtons",
  }

  if keybind then
    opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
  end

  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = opts,
  }
end

local function footer()
  local date = os.date("  %d/%m/%Y ")
  local time = os.date("  %H:%M:%S ")

  local v = vim.version()
  local version = "  v" .. v.major .. "." .. v.minor .. "." .. v.patch

  return date .. time .. version
end

function M.config()
  require("alpha").setup({
    layout = {
      { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
      {
        type = "text",
        opts = {
          position = "center",
          hl = "AlphaHeader",
        },
        val = {
          [[                                    ]],
          [[   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆           ]],
          [[    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦        ]],
          [[          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄      ]],
          [[           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄     ]],
          [[          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀    ]],
          [[   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄   ]],
          [[  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄    ]],
          [[ ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄   ]],
          [[ ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄  ]],
          [[      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆      ]],
          [[       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃      ]],
          [[                                    ]],
        }
      },
      { type = "padding", val = 1 },
      {
        type = "group",
        val = {
          button("SPC r F", "  Recent File", ":Telescope oldfiles<CR>"),
          button("SPC f f", "  Find File", ":Telescope find_files<CR>"),
          button("SPC f g", "  Find Word", ":Telescope live_grep<CR>"),
          button("SPC f m", "  Bookmarks", ":Telescope marks<CR>"),
          button("SPC q", "  Exit Neovim", ":qa<CR>"),
        },
      },
      { type = "padding", val = 1 },
      {
        type = "text",
        val = footer(),
        opts = {
          position = "center",
          hl = "Constant",
        }
      }
    }
  })

  vim.cmd [[autocmd User AlphaReady let b:miniindentscope_disable=v:true]]
end

return M
