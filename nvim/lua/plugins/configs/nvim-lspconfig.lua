local nvim_lsp = require("lspconfig")

-- Use an on_attach function to only map keys after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Set formatting on save
  -- vim.api.nvim_command[[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]

  -- Attach LSP signatures
  require("lsp_signature").on_attach()

  -- Show diagnostics in floating window on cursor
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor"
      }

      vim.diagnostic.open_float(nil, opts)
    end
  })

  -- Mappings
  -- See `:help vim.lsp.*` for documentation on any of the below functions

  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)

  -- NOTE: I use Telescope for definitions now, as it's easier to browse
  --   buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  buf_set_keymap('n', '<space>cwa',
                 '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', {
    desc = "Add Folder to Workspace",
    noremap = true,
    silent = true
  })
  buf_set_keymap('n', '<space>cwr',
                 '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', {
    desc = "Remove Folder from Workspace",
    noremap = true,
    silent = true
  })
  buf_set_keymap('n', '<space>cwl',
                 '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                 { desc = "List Workspace", noremap = true, silent = true })

  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
  --                { desc = "Show Type Definition", noremap = true, silent = true })

  buf_set_keymap('n', '<space>cr', '<cmd>lua vim.lsp.buf.rename()<CR>',
                 { desc = "Rename Symbol", noremap = true, silent = true })
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                 { desc = "Code Actions", noremap = true, silent = true })

  -- NOTE: I use Telescope for references now, as it's easier to browse
  --   buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  buf_set_keymap('n', '<space>e',
                 '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', {
    desc = "Show Line Diagnostics",
    noremap = true,
    silent = true
  })
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', {
    desc = "Diagnostics to loclist",
    noremap = true,
    silent = true
  })
  -- buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = nil
if type(cmp_nvim_lsp.default_capabilities) == "function" then
  capabilities = cmp_nvim_lsp.default_capabilities()
else
  capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol
                                                    .make_client_capabilities())
end

local M = {}

M.on_attach = on_attach
M.capabilities = capabilities

M.setup = function()
  vim.diagnostic.config({
    signs = true,
    float = { source = "always", border = "rounded", prefix = " " },
    virtual_text = {
      source = "always",
      format = function(diagnostic)
        if #diagnostic.message > 60 then
          return string.sub(diagnostic.message, 1, 60) .. "..."
        else
          return diagnostic.message
        end
      end
    }
  })

  -- Change the border of documentation hover windows
  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                                                     vim.lsp.handlers
                                                       .signature_help,
                                                     { border = "rounded" })

  -- Setup the Python and TypeScript servers

  local servers = { 'pyright', 'tsserver' }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      flags = { debounce_text_changes = 150 },
      capabilities = capabilities
    }
  end

  -- Setup the clangd server

  local clangd_path = "/usr/bin/clangd"
  if vim.loop.os_uname().sysname == "Darwin" then
    clangd_path = "/opt/homebrew/opt/llvm/bin/clangd"
  end

  nvim_lsp.clangd.setup {
    cmd = { clangd_path },
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
    capabilities = capabilities
  }

  -- Setup the Lua server
  nvim_lsp.sumneko_lua.setup {
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' }
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true)
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = { enable = false }
      }
    }
  }

  -- Setup Solidity
  nvim_lsp.solidity_ls.setup { on_attach = on_attach }

  -- NOTE: Rust is activated in 'rust-tools.lua'
end

return M
