-- LSP support
--
-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/SmiteshP/nvim-navic (used in the statusline)

local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- "hrsh7th/cmp-nvim-lsp",
    "SmiteshP/nvim-navic",
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

local CONFORM_FT = { javascript = true, typescript = true }

function M.formatting.format()
  if M.formatting.autoformat then
    if CONFORM_FT[vim.bo.filetype] then
      require("conform").format()
      return
    elseif vim.lsp.buf.format then
      vim.lsp.buf.format()
    else
      vim.lsp.buf.formatting_sync()
    end
  end
end

function M.formatting.setup(client, bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

  local enable = true
  if CONFORM_FT[ft] then
    enable = false
  end

  client.server_capabilities.documentFormattingProvider = enable

  vim.cmd([[
    augroup LspFormat
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> lua require("plugins.lsp").formatting.format()
    augroup END
  ]])
end

function M.show_documentation()
  print("Show_documne")
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
  M.formatting.setup(client, bufnr)

  -- Mappings
  -- See `:help vim.lsp.*` for documentation on any of the below functions

  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

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

  buf_set_keymap('n', '<space>cr', '<cmd>lua vim.lsp.buf.rename()<CR>',
    { desc = "Rename symbol", noremap = true, silent = true })
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
    { desc = "Code actions", noremap = true, silent = true })

  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', {
    desc = "Diagnostics to loclist",
    noremap = true,
    silent = true
  })
end

function M.get_capabilities()
  if M.capabilities then
    return M.capabilities
  end

  M.capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok, blink_cmp = pcall(require, "blink-cmp")
  if ok then
    M.capabilities = blink_cmp.get_lsp_capabilities(M.capabilities)
  else
    vim.notify("Failed to load blink-cmp", vim.log.levels.WARN)
  end

  return M.capabilities
end

function M.init()
  local nvim_lsp = require("lspconfig")

  -- Get our initial set of capabilities
  local capabilities = M.get_capabilities()

  -- Setup the Python, TypeScript, and tailwind servers
  local servers = { 'pyright', 'ts_ls', 'tailwindcss', 'gdscript' }
  for _, lsp in ipairs(servers) do
    vim.lsp.enable(lsp)
    vim.lsp.config(lsp, {
      capabilities = capabilities,
      on_attach = M.on_attach,
      flags = { debounce_text_changes = 150 }
    })
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

  vim.lsp.enable("clangd")
  vim.lsp.config("clangd", {
    cmd = { clangd_path },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    on_attach = M.on_attach,
    flags = { debounce_text_changes = 150 },
    capabilities = vim.tbl_extend("force", {}, capabilities, {
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
      offsetEncoding = { "utf-16" }
    })
  })

  -- Setup the Go server
  vim.lsp.enable("gopls")
  vim.lsp.config("gopls", {
    on_attach = M.on_attach,
    capabilities = capabilities,
    -- flags = { debounce_text_changes = 150 }
  })

  -- Setup the Lua server
  vim.lsp.enable("lua_ls")
  vim.lsp.config("lua_ls", {
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
  })

  -- Setup JDTLS server for Java
  vim.lsp.enable("jdtls")
  vim.lsp.config("jdtls", {
    on_attach = M.on_attach,
    capabilities = capabilities,
    -- cmd = { "jdtls" },
    -- root_dir = function(fname)
    --   return nvim_lsp.util.root_pattern("pom.xml", "build.gradle", "settings.gradle", ".git")(fname) or
    --       nvim_lsp.util.path.dirname(fname)
    -- end,
    -- settings = {
    --   java = {
    --     format = {
    --       enabled = true,
    --       -- settings = {
    --       --   url = "https://raw.githubusercontent.com/blakeblackshear/javac-format/main/src/main/resources/formatter.xml"
    --       -- }
    --     }
    --   }
    -- }
  })

  -- NOTE: Rust is now activated in 'rustaceanvim.lua'
end

return M
