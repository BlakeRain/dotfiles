-- Autocompletion
-- https://github.com/hrsh7th/nvim-cmp

local M = {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-emoji',
    'f3fora/cmp-spell',
    'onsails/lspkind-nvim',
    'ray-x/lsp_signature.nvim',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
  },
  event = "InsertEnter"
}

function M.config()
  local cmp = require("cmp");
  local lspkind = require("lspkind");

  cmp.setup({
    snippet = {
      expand = function(args) require("luasnip").lsp_expand(args.body) end
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered()
    },
    formatting = {
      format = lspkind.cmp_format({
        with_text = true,
        menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[Latex]"
        })
      })
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-e>'] = cmp.mapping(
        { i = cmp.mapping.abort(), c = cmp.mapping.close() }),
      ['<C-j>'] = cmp.mapping.confirm({ select = false })
      -- ['<CR>'] = cmp.mapping.confirm({ select = false })
    }),
    sources = cmp.config.sources({
      -- { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'luasnip' }
    }, {
      { name = 'buffer' }, { name = "spell" },
      { name = "emoji" }
    })
  })

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline({}),
    sources = { { name = 'buffer' } }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline({}),
    sources = cmp.config
        .sources({ { name = 'path' } }, { { name = 'cmdline' } })
  })
end

return M
