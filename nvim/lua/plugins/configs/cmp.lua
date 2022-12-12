local cmp = require("cmp");
local lspkind = require("lspkind");

local M = {}
M.setup = function()
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
      { name = 'copilot' }, { name = 'nvim_lsp' }, { name = 'nvim_lua' },
      { name = 'luasnip' }
    }, {
      { name = 'buffer' }, { name = "spell" }, { name = "calc" },
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
