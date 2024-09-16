-- Configuration for global key bindings
--
-- Note that this is not an entirely complete set of all keymaps, as individual plugins will also
-- bind additional keys.

-- <Leader><Space> toggles folded regions
vim.keymap.set("n", "<Leader><Space>", "zA")

-- Setup a keybinding to toggle the folding of code.
--
-- This will switch the code folding between 'expr' (which uses treesitter) and 'manual', and
-- display a notification to indicate the change to the fold method.
--
-- If the fold method is changed to 'manual', the 'foldlevel' will be set to 9000 to ensure that all
-- folds are open. If the fold method is changed to 'expr', the 'foldlevel' is set to zero to
-- collapse all folds.
vim.keymap.set("n", "<Leader>cf", function()
  local method = vim.api.nvim_get_option_value("foldmethod", { win = 0 })
  local new_method = nil
  local fold_level = 0

  if method == "manual" then
    new_method = "expr"
  else
    new_method = "manual"
    fold_level = 99
  end

  vim.notify("Setting fold method to '" .. new_method .. "'", vim.log.levels.INFO,
    { title = "NVim Folding" })

  vim.api.nvim_set_option_value("foldmethod", new_method, { win = 0 })
  vim.api.nvim_set_option_value("foldlevel", fold_level, { win = 0 })
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
vim.keymap.set("n", "<leader>ss",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search & replace word" })

vim.keymap.set("n", "<leader>se", function()
  require("scissors").editSnippet()
end, { desc = "Edit snippets" })

vim.keymap.set({ "n", "x" }, "<leader>sa", function()
  require("scissors").addNewSnippet()
end, { desc = "Add a new snippet" })

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
for i = 1, 9 do
  vim.keymap.set("n", "<leader>w" .. i, ":" .. i .. "wincmd w<cr>",
    { desc = "Goto window " .. i })
end

-- Close the current window
vim.keymap.set('n', '<leader>wc', ":close<CR>")

-- Maximize the current window (see the plugin "szw/vim-maximizer")
vim.keymap.set('n', '<leader>wz', ':MaximizerToggle<CR>')

-- Use GPT-3 to explain a function (adds a comment at the start of the function).
vim.keymap.set("n", "<Leader>coe", ":OpenAIExplainFunction<CR>",
  { desc = "OpenAI explain function" })

-- Use GPT-3 to explain some code (adds a comment at the start of the code).
vim.keymap.set("v", "<Leader>coe", ":OpenAIExplainCode<CR>",
  { desc = "OpenAI explain selected code" })

-- Use GPT-3 to complete some code at the cursor location.
vim.keymap.set("i", "<C-e>", ":OpenAIComplete<CR>", { desc = "OpenAI complete" })

-- Run a quick GPT-3 query, display the result in a split.
vim.keymap.set("n", "<Leader>coq", ":OpenAIQuery<CR>", { desc = "OpenAI query" })
vim.keymap.set("v", "<Leader>coq", ":OpenAIQuery<CR>",
  { desc = "OpenAI query (selection)" })

-- Open the GPT-3 chat window (see the 'custom/chatgpt.lua' module).
vim.keymap.set("n", "<Leader>coc", ":ChatGPT<CR>", { desc = "OpenAI ChatGPT" })
-- Open the GPT-3 chat window (see the 'custom/chatgpt.lua' module), use current selection as prompt.
vim.keymap.set("v", "<Leader>coc", ":ChatGPT<CR>",
  { desc = "OpenAI ChatGPT (selected prompt)" })

-- Open the GPT-3 chat window (see the 'custom/chatgpt.lua' module), restoring the last chat.
vim.keymap.set("n", "<Leader>coC", ":ChatGPT!<CR>",
  { desc = "OpenAI ChatGPT (restore last)" })
-- Open the GPT-3 chat window (see the 'custom/chatgpt.lua' module), use current selection as prompt.
vim.keymap.set("v", "<Leader>coC", ":ChatGPT!<CR>",
  { desc = "OpenAI ChatGPT (restore last, selected prompt)" })

-- Append the selection to a new chat session as part of the prompt, but don't send it yet.
vim.keymap.set("v", "<Leader>coa", ":ChatGPTAppend<CR>",
  { desc = "OpenAI ChatGPT (insert selectection)" })
-- Append the selection to the last chat session as part of the prompt, but don't send it yet.
vim.keymap.set("v", "<Leader>coA", ":ChatGPTAppend!<CR>",
  { desc = "OpenAI ChatGPT (restore last, insert selection)" })

-- See if GPT-3 can create us a commit message (stored in the clipboard).
vim.keymap.set("n", "<leader>com", ":OpenAICommitMessage<CR>",
  { desc = "Generate Commit Message" })

-- Execute the file as a Lua script.
vim.keymap.set("n", "<leader>cx", "<CMD>luafile %<CR>", { desc = "Run as Lua" })

-- If the buffer has an '__automake' local set, then run the 'make' command after saving the buffer. This is useful to
-- automatically run 'make' when we save changes. Use `<leader>cm` (defined below) to toggle the effect on the buffer.
local automake_group = vim.api.nvim_create_augroup("AutoMakeGroup",
  { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = automake_group,
  callback = function() if vim.b.__automake then vim.cmd [[make!]] end end
})

-- Toggle the 'automake' effect on the current buffer.
vim.keymap.set("n", "<Leader>cm", function()
  vim.b.__automake = not vim.b.__automake
  local mode = "DISABLED"
  if vim.b.__automake then mode = "ENABLED" end
  vim.notify("Automatically running make on save is " .. mode, vim.log.levels.INFO,
    { title = "Running Make on Save" })
end, { desc = "Run 'make' on save" })

-- Replace word options: 'cn' will replace the current word, and use '.' to repeat. Use 'n' to skip a match. Note that
-- 'cN' is the reverse. This also adds `cq` (and it's opposite direction `cQ`), which allows running a macro.
--
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
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
