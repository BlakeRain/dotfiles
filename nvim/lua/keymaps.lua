--
-- Key Mappings
--
local utils = require('core.utils')
local has_notify, notify = pcall(require, "notify")

-- <Leader><Space> toggles folded regions
utils.map("n", "<Leader><Space>", "zA")

-- Setup a keybinding to toggle the folding of code.
--
-- This will switch the code folding between 'expr' (which uses treesitter) and 'manual', and display a notification
-- to indicate the change to the fold method.
--
-- If the fold method is changed to 'manual', the 'foldlevel' will be set to 9000 to ensure that all folds are open.
-- If the fold method is changed to 'expr', the 'foldlevel' is set to zero to collapse all folds.
utils.map("n", "<Leader>cf", function()
  local method = vim.api.nvim_win_get_option(0, "foldmethod")
  local new_method = nil
  local fold_level = 0

  if method == "manual" then
    new_method = "expr"
  else
    new_method = "manual"
    fold_level = 9000
  end

  notify.notify("Setting fold method to '" .. new_method .. "'", "info",
                { title = "NVim Folding" })
  vim.api.nvim_win_set_option(0, "foldmethod", new_method)
  vim.api.nvim_win_set_option(0, "foldlevel", fold_level)
end, { desc = "Toggle Folding" })

-- Map a keybinding to open the quick-fix list
utils.map("n", "<Leader>qf", "<CMD>copen<CR>", { desc = "Open Quickfix List" })

-- Reselect visual selection after indent.
utils.map('v', '<', '<gv')
utils.map('v', '>', '>gv')

-- Clear the current highlight with <leader>k.
utils.map('n', '<leader>k', ':nohlsearch<CR>', { desc = "Clear Highlight" })

-- Use 'gf' to go to a file, even if it doesn't exist yet.
utils.map('n', 'gf', ':edit <cfile><cr>')

-- Use 'gF' to 'open' a file.
-- NOTE: This doesn't do a <CR>, which means we need to press it ourselves.
utils.map('n', 'gF', ':! open <cfile>', { desc = "Select last paste" })

-- Use 'gpp' to select pasted text (after pasting).
utils.map('n', 'gpp', '`[v`]')

-- Select windows by number.
utils.map('n', '<leader>w1', ':1wincmd w <cr>')
utils.map('n', '<leader>w2', ':2wincmd w <cr>')
utils.map('n', '<leader>w3', ':3wincmd w <cr>')
utils.map('n', '<leader>w4', ':4wincmd w <cr>')
utils.map('n', '<leader>w5', ':5wincmd w <cr>')
utils.map('n', '<leader>w6', ':6wincmd w <cr>')
utils.map('n', '<leader>w7', ':7wincmd w <cr>')
utils.map('n', '<leader>w8', ':8wincmd w <cr>')
utils.map('n', '<leader>w9', ':9wincmd w <cr>')

for i = 1, 9 do
  utils.map("n", "<leader>w" .. i, ":" .. i .. "wincmd w<cr>",
            { desc = "Goto Window " .. i })
end

utils.map("n", "<leader>cx", "<CMD>luafile %<CR>", { desc = "Run as Lua" })

local automake_group = vim.api.nvim_create_augroup("AutoMakeGroup",
                                                   { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = automake_group,
  callback = function() if vim.b.__automake then vim.cmd [[make]] end end
})

utils.map("n", "<Leader>cm", function()
  vim.b.__automake = not vim.b.__automake
  local mode = "DISABLED"
  if vim.b.__automake then mode = "ENABLED" end
  notify.notify("Automatically running make on save is " .. mode, "info",
                { title = "Running Make on Save" })
end, { desc = "Run 'make' on save" })

vim.cmd([[
let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"

nnoremap cn *``cgn
nnoremap cN *``cgN

vnoremap <expr> cn g:mc . "``cgn"
vnoremap <expr> cN g:mc . "``cgN"

function! SetupCR()
  nnoremap <Enter> :nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z
endfunction

nnoremap cq :call SetupCR()<CR>*``qz
nnoremap cQ :call SetupCR()<CR>#``qz

vnoremap <expr> cq ":\<C-u>call SetupCR()\<CR>" . "gv" . g:mc . "``qz"
vnoremap <expr> cQ ":\<C-u>call SetupCR()\<CR>" . "gv" . substitute(g:mc, '/', '?', 'g') . "``qz"
]])
