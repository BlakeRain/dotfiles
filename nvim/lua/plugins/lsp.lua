-- LSP support
-- https://github.com/neovim/nvim-lspconfig
local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "SmiteshP/nvim-navic"
  },
}

M.formatting = {}
M.formatting.autoformat = true

function M.formatting.toggle()
  M.formatting.autoformat = not M.formatting.autoformat
  local msg = M.formatting.autoformat and "Enabled" or "Disabled"
  local notify = require("plugins.notify")
  notify.info(msg .. " format on save", { title = "Formatting" })
end

function M.formatting.format()
  if M.formatting.autoformat then
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    else
      vim.lsp.buf.formatting_sync()
    end
  end
end

function M.formatting.setup(client, bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

  local enable = true
  if client.name == "tsserver" then
    enable = false
  end

  client.server_capabilities.documentFormattingProvider = enable
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd([[
    augroup LspFormat
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> lua require("plugins.lsp").formatting.format()
    augroup END
    ]])
  end
end

function M.show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand("<cword>"))
  elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
    require("crates").show_popup()
  else
    vim.lsp.buf.hover()
  end
end

-- Use an on_attach function to only map keys after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Attach nvim-navic to the LSP server if 'documentSymbolProvider' is present
  if client.server_capabilities.documentSymbolProvider then
    local ok, navic = pcall(require, "nvim-navic")
    if ok then
      navic.attach(client, bufnr)
    else
      vim.notify("Failed to load nvim-navic", vim.log.levels.WARN)
    end
  end

  -- Set formatting on save
  -- vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
  M.formatting.setup(client, bufnr)

  -- Attach LSP signatures
  require("lsp_signature").on_attach()

  -- Enable inlay hints
  -- vim.lsp.inlay_hint.enable(bufnr, true)
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

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
  -- buf_set_keymap('n', 'K', M.show_documentation, opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  buf_set_keymap('n', '<space>cwa',
    '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', {
      desc = "Add folder to workspace",
      noremap = true,
      silent = true
    })
  buf_set_keymap('n', '<space>cwr',
    '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', {
      desc = "Remove folder from workspace",
      noremap = true,
      silent = true
    })
  buf_set_keymap('n', '<space>cwl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    { desc = "List workspace", noremap = true, silent = true })

  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
  --                { desc = "Show Type Definition", noremap = true, silent = true })

  buf_set_keymap('n', '<space>cr', '<cmd>lua vim.lsp.buf.rename()<CR>',
    { desc = "Rename symbol", noremap = true, silent = true })
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
    { desc = "Code actions", noremap = true, silent = true })

  -- NOTE: I use Telescope for references now, as it's easier to browse
  --   buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  -- buf_set_keymap('n', '<space>e',
  --   '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', {
  --     desc = "Show line diagnostics",
  --     noremap = true,
  --     silent = true
  --   })
  -- See `plugins/mini` as `mini-bracketed` is doing this now
  -- buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', {
    desc = "Diagnostics to loclist",
    noremap = true,
    silent = true
  })
  -- buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

function M.get_capabilities()
  if M.capabilities then
    return M.capabilities
  end

  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  if type(cmp_nvim_lsp.default_capabilities) == "function" then
    M.capabilities = cmp_nvim_lsp.default_capabilities()
  else
    M.capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol
      .make_client_capabilities())
  end

  return M.capabilities
end

function M.config()
  local nvim_lsp = require("lspconfig")

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

  -- Get our initial set of capabilities
  local capabilities = M.get_capabilities()

  -- Setup the Python and TypeScript servers

  local servers = { 'pyright', 'tsserver', 'tailwindcss' }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = M.on_attach,
      flags = { debounce_text_changes = 150 },
      capabilities = capabilities
    }
  end

  -- Setup the clangd server

  local clangd_path = nil
  if vim.fn.filereadable("/usr/bin/clangd") == 1 then
    clangd_path = "/usr/bin/clangd"
  elseif vim.loop.os_uname().sysname == "Darwin" and
      vim.fn.filereadable("/opt/homebrew/opt/llvm/bin/clangd") == 1 then
    clangd_path = "/opt/homebrew/opt/llvm/bin/clangd"
  elseif vim.fn.filereadable("/home/blake/.local/share/nvim/mason/bin/clangd") then
    clangd_path = "/home/blake/.local/share/nvim/mason/bin/clangd"
  else
    print("Unable to locate 'clangd'")
  end

  nvim_lsp.clangd.setup {
    cmd = { clangd_path },
    on_attach = M.on_attach,
    flags = { debounce_text_changes = 150 },
    capabilities = vim.tbl_extend("force", {}, capabilities, {
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
      offsetEncoding = { "utf-16" }
    })
  }

  -- Setup the Lua server
  nvim_lsp.lua_ls.setup {
    on_attach = M.on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          -- Get the langauge server to recognize the `vim` global
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
  nvim_lsp.solidity_ls
      .setup { on_attach = M.on_attach, capabilities = capabilities }

  -- Setup the Java server
  nvim_lsp.jdtls.setup {
    cmd = { "jdtls" },
    on_attach = M.on_attach,
    capabilities = capabilities,
  }

  -- NOTE: Rust is now activated in 'rustaceanvim.lua'
end

return M
