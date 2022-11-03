--
-- Vim Options
--
-- General options controlling the behavior of Vim.
--
-- Disable some providers that we don't use.
vim.cmd([[
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
]])

-- Display various whitespace characters
vim.opt.list = true
vim.opt.listchars = {
  eol = "⏎",
  tab = "⇥ ",
  trail = "~",
  extends = "→",
  precedes = "←"
}

-- Add line numbering.
vim.opt.number = true

-- Use relative line numbering.
vim.opt.relativenumber = true

-- Set the scroll offsets to something reasonable to avoid hitting the edges of the window.
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

-- Set the default encoding to UTF-8.
vim.opt.encoding = 'utf-8'

-- Configure spelling, but don't enable it by default.
vim.opt.spell = false
vim.opt.spelllang = { 'en_gb' }

-- Create an augroup for spelling, which enables spelling for Markdown, text and Roff files.
local spell_group = vim.api
                      .nvim_create_augroup("SpellingSets", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.md", "*.txt", "*.mm", "*.ms", "*.mom" },
  group = spell_group,
  command = "setlocal spell"
})

-- Map the leader key to space.
vim.g.mapleader = ' '

-- Tell vim about our terminal color support.
vim.cmd([[
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = '\<Esc>[38;2;%lu;%lu;%lum'
  let &t_8b = '\<Esc>[48;2;%lu;%lu;%lum'
endif
]])
vim.opt.termguicolors = true

-- Set the floating-window blending to 10 (percent?).
vim.opt.winblend = 10

-- Add a ruler at column 120.
vim.opt.colorcolumn = '120'

-- Set the width of formatted text to column 120 (we're modern now).
vim.opt.textwidth = 120

-- Highlight the current line.
vim.opt.cursorline = true

-- Highlight found searches.
vim.opt.hlsearch = true

-- Show match while typing.
vim.opt.incsearch = true

-- Get a preview of replacements.
vim.opt.inccommand = 'split'

-- Don't ignore case with capitals.
vim.opt.smartcase = true

-- Set the tab size to two by default and replace tabs with spaces
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Set the behaviour of the backspace key.
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- Use the system clipboard.
vim.opt.clipboard = 'unnamedplus'

-- Improve the autocompletion menus.
vim.opt.completeopt = 'menu,menuone,noselect'

-- Tell vim that we use fish.
vim.opt.shell = 'fish'

-- Enable use of the mouse in all vim modes.
vim.opt.mouse = 'a'

-- Enable background buffers.
vim.opt.hidden = true

-- Put new windows below the current or to the right of current.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Configure undo directory
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'
vim.opt.undofile = true

-- Don't do the whole backup thing.
-- NOTE: Disabled because I actually ended up needing the backups.
-- vim.opt.nobackup = true
-- vim.opt.nowritebackup = true

-- Give us a bit more space for displaying messages.
vim.opt.cmdheight = 2

-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess:append({ c = true })

-- Having a longer updatetime (default is 4000ms) leads to noticeable delays and poor UXP.
vim.opt.updatetime = 300

-- Merge the sign column and number column into one.
vim.opt.signcolumn = 'yes'

-- Use a global statusline.
vim.opt.laststatus = 3

-- Include some languages in Markdown.
vim.g.markdown_fenced_languages = {
  'html', 'python', 'css', 'javascript', 'typescript', 'rust'
}

-- Setup folding.
-- NOTE: I don't actually set the 'foldmethod' here, as I have a keybinding to toggle it (see 'keymaps.lua')
-- vim.cmd('set foldmethod=expr')
vim.cmd('set foldexpr=nvim_treesitter#foldexpr()')

-- Tell rust that we want to override the "recommended" style
vim.g.rust_recommended_style = 0

-- Create an augroup for Rust that sets the textwidth to 120 (rather than the mandated 100)
local rust_group = vim.api.nvim_create_augroup("RustSettings", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.rs" },
  group = rust_group,
  callback = function(info)
    -- setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
    vim.api.nvim_buf_set_option(info.buf, "textwidth", 119)
    vim.api.nvim_buf_set_option(info.buf, "tabstop", 4)
    vim.api.nvim_buf_set_option(info.buf, "shiftwidth", 4)
    vim.api.nvim_buf_set_option(info.buf, "softtabstop", 4)
    vim.api.nvim_buf_set_option(info.buf, "expandtab", true)
  end
})
