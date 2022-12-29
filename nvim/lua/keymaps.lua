local has_notify, notify = pcall(require, "notify")

-- <Leader><Space> toggles folded regions
vim.keymap.set("n", "<Leader><Space>", "zA")

-- Setup a keybinding to toggle the folding of code.
--
-- This will switch the code folding between 'expr' (which uses treesitter) and 'manual', and display a notification
-- to indicate the change to the fold method.
--
-- If the fold method is changed to 'manual', the 'foldlevel' will be set to 9000 to ensure that all folds are open.
-- If the fold method is changed to 'expr', the 'foldlevel' is set to zero to collapse all folds.
vim.keymap.set("n", "<Leader>cf", function()
  local method = vim.api.nvim_win_get_option(0, "foldmethod")
  local new_method = nil
  local fold_level = 0

  if method == "manual" then
    new_method = "expr"
  else
    new_method = "manual"
    fold_level = 9000
  end

  if has_notify then
    notify.notify("Setting fold method to '" .. new_method .. "'", "info",
      { title = "NVim Folding" })
  end
  vim.api.nvim_win_set_option(0, "foldmethod", new_method)
  vim.api.nvim_win_set_option(0, "foldlevel", fold_level)
end, { desc = "Toggle folding" })

-- Map a keybinding to open the quick-fix list
vim.keymap.set("n", "<Leader>qf", "<CMD>copen<CR>", { desc = "Open quickfix list" })

-- Reselect visual selection after indent.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Drag things up and down in visual selection mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join lines, but keep cursor where it is
vim.keymap.set("n", "J", "mzJ`z")

-- Centre cursor when going up and down
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Centre cursor when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- When using 'x', don't yank the deleted character into a register
vim.keymap.set('n', 'x', '"_x')

-- Clear the current highlight with <leader>k.
vim.keymap.set('n', '<leader>k', ':nohlsearch<CR>', { desc = "Clear highlight" })

-- Delete to the void register
vim.keymap.set("n", "<leader>d", "\"_d", { desc = "Delete (to void register)" })
vim.keymap.set("v", "<leader>d", "\"_d", { desc = "Delete (to void register)" })

-- Begin a search/replace with the current word under the cursor
vim.keymap.set("n", "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search & replace word" })

-- Paste without replacing the contents of the register
vim.keymap.set("x", "<leader>p", "\"_dP",
  { desc = "Paste (without register overwrite)" })

-- Use 'gf' to go to a file, even if it doesn't exist yet.
vim.keymap.set('n', 'gf', ':edit <cfile><cr>')

-- Use 'gF' to 'open' a file.
-- NOTE: This doesn't do a <CR>, which means we need to press it ourselves.
vim.keymap.set('n', 'gF', ':! open <cfile>', { desc = "Open file/URL under cursor" })

-- Use 'gpp' to select pasted text (after pasting).
vim.keymap.set('n', 'gpp', '`[v`]', { desc = "Select pasted text" })

-- Select windows by number.
vim.keymap.set('n', '<leader>w1', ':1wincmd w <CR>')
vim.keymap.set('n', '<leader>w2', ':2wincmd w <CR>')
vim.keymap.set('n', '<leader>w3', ':3wincmd w <CR>')
vim.keymap.set('n', '<leader>w4', ':4wincmd w <CR>')
vim.keymap.set('n', '<leader>w5', ':5wincmd w <CR>')
vim.keymap.set('n', '<leader>w6', ':6wincmd w <CR>')
vim.keymap.set('n', '<leader>w7', ':7wincmd w <CR>')
vim.keymap.set('n', '<leader>w8', ':8wincmd w <CR>')
vim.keymap.set('n', '<leader>w9', ':9wincmd w <CR>')
vim.keymap.set('n', '<leader>wc', ":close<CR>")
vim.keymap.set('n', '<leader>wz', ':MaximizerToggle<CR>')

vim.keymap.set("n", "<Leader>coe", ":OpenAIExplainFunction<CR>",
  { desc = "OpenAI explain function" })

vim.keymap.set("v", "<Leader>coe", ":OpenAIExplainCode<CR>",
  { desc = "OpenAI explain selected code" })

vim.keymap.set("i", "<C-e>", ":OpenAIComplete<CR>", { desc = "OpenAI complete" })

vim.keymap.set("n", "<Leader>coq", ":OpenAIQuery<CR>", { desc = "OpenAI query" })
vim.keymap.set("v", "<Leader>coq", ":OpenAIQuery<CR>",
  { desc = "OpenAI query (selection)" })

vim.keymap.set("n", "<Leader>coc", ":ChatGPT<CR>", { desc = "OpenAI ChatGPT" })
vim.keymap.set("v", "<Leader>coc", ":ChatGPT<CR>",
  { desc = "OpenAI ChatGPT (selected prompt)" })

vim.keymap.set("n", "<Leader>coC", ":ChatGPT!<CR>",
  { desc = "OpenAI ChatGPT (restore last)" })
vim.keymap.set("v", "<Leader>coC", ":ChatGPT!<CR>",
  { desc = "OpenAI ChatGPT (restore last, selected prompt)" })

vim.keymap.set("v", "<Leader>coa", ":ChatGPTAppend<CR>",
  { desc = "OpenAI ChatGPT (insert selectection)" })
vim.keymap.set("v", "<Leader>coA", ":ChatGPTAppend!<CR>",
  { desc = "OpenAI ChatGPT (restore last, insert selection)" })

for i = 1, 9 do
  vim.keymap.set("n", "<leader>w" .. i, ":" .. i .. "wincmd w<cr>",
    { desc = "Goto window " .. i })
end

vim.keymap.set("n", "<leader>cx", "<CMD>luafile %<CR>", { desc = "Run as Lua" })

local automake_group = vim.api.nvim_create_augroup("AutoMakeGroup",
  { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = automake_group,
  callback = function() if vim.b.__automake then vim.cmd [[make]] end end
})

vim.keymap.set("n", "<Leader>cm", function()
  vim.b.__automake = not vim.b.__automake
  local mode = "DISABLED"
  if vim.b.__automake then mode = "ENABLED" end
  if has_notify then
    notify.notify("Automatically running make on save is " .. mode, "info",
      { title = "Running Make on Save" })
  end
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
