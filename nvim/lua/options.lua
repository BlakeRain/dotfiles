-- General options controlling the behaviour of neovim.

-- Disable some providers that we don't use.
vim.cmd [[
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
]]

-- Change the display of whitespace characters.
vim.opt.list = true
vim.opt.listchars = {
  eol = "⏎",
  tab = "⇥ ",
  trail = "~",
  extends = "→",
  precedes = "←"
}

-- Add line numbering, and use relative numbers.
vim.opt.number = true
vim.opt.relativenumber = true

-- Switch between relative and absolute line numbers depending on whether we're in insert mode.
vim.cmd [[
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber
]]

-- Set the title to something corresponding to the project.
vim.opt.title = true
vim.opt.titlestring = " %{pathshorten(substitute(getcwd(),$HOME,'~',''))}"

-- Set the scroll offsets to something reasonable to avoid hitting the edges of the window.
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

-- Disable netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Set the default encoding to UTF-8.
vim.opt.encoding = "utf-8"

-- Configure spelling, but don't enable it by default.
vim.opt.spell = false
vim.opt.spelllang = { "en_gb" }

-- Create an augroup for spelling, which enables spelling for Markdown, text and Roff files.
local spell_group = vim.api.nvim_create_augroup("SpellingSets", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.md", "*.txt", "*.mm", "*.ms", "*.mom" },
  group = spell_group,
  command = "setlocal spell"
})

-- Map the leader key to space.
vim.g.mapleader = " "

-- Tell neovim about our terminal color support.
vim.opt.termguicolors = true
vim.cmd [[
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = '\<Esc>[38;2;%lu;%lu;%lum'
  let &t_8b = '\<Esc>[48;2;%lu;%lu;%lum'
endif
]]

-- Set the floating-window blending to 10 (percent?).
vim.opt.winblend = 10

-- Add a ruler at column 100
vim.opt.colorcolumn = '100'

-- Set the width of formatted text to column 100 (unless overridden elsewhere).
vim.opt.textwidth = 100

-- Highlight the current line.
vim.opt.cursorline = true

-- Highlight found searches, and show the match whilst we're typing.
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Get a preview of the replacements when using search and replace.
vim.opt.inccommand = 'split'

-- Ignore case in search, unless we start using case.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set the tab size to two by default and replace tabs with spaces.
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Set the behaviour of the backspace key.
vim.opt.backspace = { "indent", "eol", "start" }

-- Use the system clipboard.
vim.opt.clipboard:append("unnamedplus")

-- Improve the auto-completion menus.
vim.opt.completeopt = "menu,menuone,noselect"

-- Tell vim that we use the zsh shell.
vim.opt.shell = "zsh"

-- Enable use of the mouse in all vim modes.
vim.opt.mouse = "a"

-- Enable background buffers.
vim.opt.hidden = true

-- Put new windows below the current or to the right.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Configure the undo directory (I like to have a lot of undo).
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

-- Don't do the whole back-up thing
-- NOTE: Disabled, because I actually ended up needing the backups.
-- vim.opt.nobackup = true
-- vim.opt.nowritebackup = true

-- Give use a bit more space for displaying messages.
-- vim.opt.cmdheight = 2

-- Don't pass messages to |ins-completion-menu|, dont't give the intro message, and dont' give
-- "written" when writing a file.
vim.opt.shortmess:append({ c = true, I = true, W = true })

-- Having a shorter updatetime leads to noticable delays and poor UXP (default is 4000ms, I think).
vim.opt.updatetime = 300

-- Merge the sign column and the number column into one.
vim.opt.signcolumn = "yes"

-- Use a global status line.
vim.opt.laststatus = 3

-- Include some language highlighting in markdown fences.
vim.g.markdown_fenced_languages = {
  "html",
  "python",
  "css",
  "javascript",
  "typescript",
  "rust"
}

-- Setup folding.
-- Note: I don't actually set the 'foldmethod' here, as I have a keybinding to toggle it (see 'keymaps.lua').
vim.cmd [[
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99
]]

-- Change the association for the 'htm' and 'html' extensions to 'htmldjango' filetype, as I spend a
-- lot of time working within Django-esque formats.
vim.filetype.add({
  extension = {
    htm = "htmldjango",
    html = "htmldjango"
  }
})

vim.fn.sign_define("DiagnosticSignError",
  { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn",
  { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo",
  { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint",
  { text = "󰌵", texthl = "DiagnosticSignHint" })

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵"
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticHint"
    }
  }
})
