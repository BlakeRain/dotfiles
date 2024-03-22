local ht = require("haskell-tools")
local bufnr = vim.api.nvim_get_current_buf()

local function map(mode, key, action, desc)
  vim.keymap.set(mode, key, action, {
    noremap = true,
    silent = true,
    buffer = bufnr,
    desc = desc
  })
end

map("n", "<space>cl", vim.lsp.codelens.run, "Run codelenses")
map("n", "<leader>hs", ht.hoogle.hoogle_signature, "Hoogle search for type signature")
map("n", "<leader>rr", ht.repl.toggle, "Toggle GHCi")
map("n", "<leader>rq", ht.repl.quit, "Quit GHCi")
map("n", "<leader>rf", function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(bufnr))
end, "Toggle GHCi (current buffer)")
