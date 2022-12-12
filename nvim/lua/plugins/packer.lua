--
-- Initialize Plugins
--
-- Make sure that packer is installed
local ensure_packer = function()
  local install_path = vim.fn.stdpath("data") ..
                         "/site/pack/packer/start/packer.nvim"
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({
      "git", "clone", "--depth", "1",
      "https://github.com/wbthomason/packer.nvim", install_path
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end

  return false
end

-- See if we have packer and if not, install it. If we've had to install it we need to perform some additional
-- operations.
local packer_boostrap = ensure_packer()

-- Create an augroup and autocommand that will reload this configuration file and run `PackerSync` when we save.
local packer_config_group = vim.api.nvim_create_augroup("PackerConfigGroup",
                                                        { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "packer.lua" },
  group = packer_config_group,
  command = "source <afile> | PackerSync"
})

-- See if we can 'require' packer; if not then we're done here
local status, packer = pcall(require, "packer")
if not status then return end

-- Function to return an eval string to load plugin configuration from path
local function load_config(name) return 'require("' .. name .. '").setup()' end

return packer.startup({
  function(use)
    use 'wbthomason/packer.nvim'

    -- Color scheme
    -- https://github.com/folke/tokyonight.nvim
    use {
      'folke/tokyonight.nvim',
      config = load_config("plugins.configs.tokyonight")
    }

    -- Actually to open file you meant
    -- https://github.com/mong8se/actually.nvim
    -- 
    -- This plugin will display a selection of files that approximate what you provided on the command-line if the
    -- file on the command-line does not exist.
    use 'mong8se/actually.nvim'

    -- Maximize and restore a window
    -- https://github.com/szw/vim-maximizer
    use { 'szw/vim-maximizer' }

    -- Treesitter for better syntax highlighting
    -- https://github.com/nvim-treesitter/nvim-treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'nvim-treesitter/playground' }

    -- Treesitter objects
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    --
    -- This lets us use treesitter text objects in vim. For example, `vas` will enter visual selection around the current
    -- statement.
    --
    -- NOTE: This does depend on the treesitter grammar for a language being useful.
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      config = load_config("plugins.configs.treesitter")
    }

    -- Treesitter context (lightweight alternative to 'context.nvim')
    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    use {
      'nvim-treesitter/nvim-treesitter-context',
      config = load_config("plugins.configs.treesitter-context")
    }

    -- TreeSJ: split or join blocks of code
    -- https://github.com/Wansmer/treesj
    use {
      'Wansmer/treesj',
      requires = { "nvim-treesitter" },
      config = load_config("plugins.configs.treesj")
    }

    -- Swap objects interactively using Treesitter
    -- https://github.com/mizlan/iswap.nvim
    --
    -- Basically this lets us use '<Leader>cs' to swap sibling treesitter objects, such as function arguments.
    use { 'mizlan/iswap.nvim', config = load_config("plugins.configs.iswap") }

    -- Treesitter auto-taggery
    -- https://github.com/windwp/nvim-ts-autotag
    use 'windwp/nvim-ts-autotag'

    -- Asynchronous co-routines for VIM
    -- https://github.com/nvim-lua/plenary.nvim
    -- 
    -- Lots of plugins need to do async, and plenary includes some good functions to help with that.
    use {
      'nvim-lua/plenary.nvim',
      config = function()
        require("core.utils").map("n", "<leader>xt", "<Plug>PlenaryTestFile",
                                  { desc = "Run Tests (Plenary)" })
      end
    }

    -- SQLite binding for NeoVim (LuaJIT)
    -- https://github.com/kkharji/sqlite.lua
    use 'kkharji/sqlite.lua'

    -- Collection of minimal modules (we use cursor-word and startup)
    -- https://github.com/echasnovski/mini.nvim
    use {
      'echasnovski/mini.nvim',
      branch = "main",
      config = load_config("plugins.configs.mini")
    }

    -- Easy foldtext customization
    -- https://github.com/anuvyklack/pretty-fold.nvim
    --
    -- This makes the foldtext (shown for a fold) somewhat nicer with some summary information. Note that this can get
    -- a bit slow for very large files.
    use {
      'anuvyklack/pretty-fold.nvim',
      config = load_config("plugins.configs.pretty-fold")
    }

    -- Preview of folds
    -- https://github.com/anuvyklack/fold-preview.nvim
    --
    -- This displays a floating preview of a fold when we press 'h' and opens the fold if we press 'l'. Quite a simple
    -- and effective plugin.
    use {
      'anuvyklack/fold-preview.nvim',
      requires = 'anuvyklack/keymap-amend.nvim',
      config = function() require('fold-preview').setup() end
    }

    -- Colorizer: highlights colors using their color
    -- https://github.com/NvChad/nvim-colorizer.lua
    --
    -- This plugin will change the background of a color (such as CSS hex) to match the actual color defined.
    --
    -- This is currently restricted to CSS-like filetypes.
    use {
      'NvChad/nvim-colorizer.lua',
      config = function()
        local colorizer = require('colorizer')
        colorizer.setup({
          filetypes = { "html", "css", "scss", "sass", "less" },
          user_default_options = {
            rgb_fn = true,
            hsl_fn = true,
            sass = { enable = true, parsers = { css = true } },
            mode = "background"
          }
        })
      end
    }

    -- Color picker
    -- https://github.com/uga-rosa/ccc.nvim
    --
    -- This plugin adds a color picker that we can display with '<Leader>cc'. If there is a color at the cursor, it will
    -- allow us to edit that color; otherwise it will create a new color.
    use {
      'uga-rosa/ccc.nvim',
      branch = "0.7.2",
      config = load_config("plugins.configs.ccc")
    }

    -- Notification manager for NeoVim
    -- https://github.com/rcarriga/nvim-notify
    --
    -- This is a nice notification manager. Hopefully more plugins will start to use it.
    use {
      'rcarriga/nvim-notify',
      config = load_config("plugins.configs.nvim-notify")
    }

    -- Telescope for searching for anything
    -- https://github.com/nvim-telescope/telescope.nvim
    --
    -- Telescope is basically how I get around things in NeoVim. Whether that is files, help, docs, manpages, LSP symbols,
    -- buffers... anything really.
    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', run = "make" },
        'nvim-telescope/telescope-file-browser.nvim',
        'nvim-telescope/telescope-cheat.nvim',
        "benfowler/telescope-luasnip.nvim"
      },
      config = load_config("plugins.configs.telescope")
    }

    -- Nice icons
    -- https://github.com/kyazdani42/nvim-web-devicons
    use {
      'kyazdani42/nvim-web-devicons',
      config = function()
        require("nvim-web-devicons").setup({ default = true })
      end
    }

    -- Compiler Explorer
    -- https://github.com/krady21/compiler-explorer.nvim
    --
    -- This lets me quickly invoke Godbolt when I need to check out what assembly code or IL a compiler is going to output
    -- for a function. I mostly use this for C++ and Rust. At some point this plugin will need some better configuration.
    use {
      'krady21/compiler-explorer.nvim',
      requires = { 'nvim-lua/plenary.nvim' }
    }

    -- Attempt: Create temporary buffers and files
    -- https://github.com/m-demare/attempt.nvim
    use {
      'm-demare/attempt.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = load_config("plugins.configs.attempt")
    }

    -- LSP support
    -- https://github.com/neovim/nvim-lspconfig
    use {
      'neovim/nvim-lspconfig',
      requires = { 'hrsh7th/cmp-nvim-lsp' },
      config = load_config("plugins.configs.nvim-lspconfig")
    }

    -- Luasnip (snippets)
    -- https://github.com/L3MON4D3/LuaSnip
    use { 'L3MON4D3/LuaSnip', config = load_config("plugins.configs.luasnip") }

    -- Autocompletion
    -- https://github.com/hrsh7th/nvim-cmp
    use {
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-calc',
        'hrsh7th/cmp-emoji', 'f3fora/cmp-spell', 'onsails/lspkind-nvim',
        'ray-x/lsp_signature.nvim', 'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip'
      },
      config = load_config("plugins.configs.cmp")
    }

    use {
      "zbirenbaum/copilot.lua",
      config = function()
        vim.defer_fn(function() require("copilot").setup() end, 100)
      end
    }

    use {
      "zbirenbaum/copilot-cmp",
      after = { "copilot.lua" },
      config = function() require("copilot_cmp").setup() end
    }

    -- Standalone UI for nvim-lsp progress
    -- https://github.com/j-hui/fidget.nvim
    use {
      'j-hui/fidget.nvim',
      config = function() require('fidget').setup({}) end
    }

    -- Pretty list of LSP diagnostic
    -- https://github.com/folke/trouble.nvim
    use { 'folke/trouble.nvim', config = load_config("plugins.configs.trouble") }

    -- Commenting code
    -- https://github.com/numToStr/Comment.nvim
    use {
      'numToStr/Comment.nvim',
      config = load_config("plugins.configs.comment")
    }

    -- Neoformat for formatting source files
    -- https://github.com/sbdchd/neoformat
    use { 'sbdchd/neoformat', config = load_config("plugins.configs.neoformat") }

    -- Status line using LUA functions
    -- https://github.com/nvim-lualine/lualine.nvim
    -- https://github.com/SmiteshP/nvim-gps
    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'SmiteshP/nvim-gps' },
      config = load_config("plugins.configs.lualine")
    }

    -- Surround things (e.g. cs'' to replace ' with '; or ysw] to enclose word in []
    -- https://github.com/tpope/vim-surround
    -- use 'http://github.com/tpope/vim-surround'
    use {
      'kylechui/nvim-surround',
      config = load_config("plugins.configs.nvim-surround")
    }

    -- Window picker thingy
    -- https://github.com/s1n7ax/nvim-window-picker
    use {
      "s1n7ax/nvim-window-picker",
      config = function() require("window-picker").setup() end
    }

    -- UI component library
    -- https://github.com/MunifTanjim/nui.nvim
    use 'MunifTanjim/nui.nvim'

    -- Display dressings for neovim
    -- https://github.com/stevearc/dressing.nvim
    use 'stevearc/dressing.nvim'

    -- File browser
    -- https://github.com/nvim-neo-tree/neo-tree.nvim
    use {
      'https://github.com/nvim-neo-tree/neo-tree.nvim',
      branch = "v2.x",
      requires = { "s1n7ax/nvim-window-picker" },
      config = load_config("plugins.configs.neo-tree")
    }

    -- Diffview support, used by neogit
    -- https://github.com/sindrets/diffview.nvim
    use 'sindrets/diffview.nvim'

    -- Provide a list of buffers in a 'tab-bar' at the top of the window without changing how vim tabs work
    -- https://github.com/romgrk/barbar.nvim
    use { 'romgrk/barbar.nvim', config = load_config("plugins.configs.barbar") }

    -- Which-key functionality to help me remember what keys are configured
    -- https://github.com/folke/which-key.nvim
    use {
      'folke/which-key.nvim',
      config = load_config("plugins.configs.which-key")
    }

    use {
      'AckslD/nvim-whichkey-setup.lua',
      requires = { 'folke/which-key.nvim' }
    }

    -- Persist and toggle terminals
    -- https://github.com/akinsho/toggleterm.nvim
    use {
      "akinsho/toggleterm.nvim",
      config = load_config("plugins.configs.toggleterm")
    }

    -- Octo: GitHub issues and PRs within Vim
    -- https://github.com/pwntester/octo.nvim
    use {
      'pwntester/octo.nvim',
      requires = {
        'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim',
        'kyazdani42/nvim-web-devicons', 'nvim-telescope/telescope-symbols.nvim',

        -- We add a requirement for our theme to ensure that Octo loads the correct colors. If we did not do this, we
        -- can end up with situations where the colors sampled from the theme by the 'octo.ui.colors' package end up
        -- being some of the original Vim colors.
        --
        -- Note: There are still some issues, which I override in the plugin configuration.
        'folke/tokyonight.nvim'
      },
      config = load_config("plugins.configs.octo")
    }

    -- Hop for moving around (like ace-jump)
    -- https://github.com/phaazon/hop.nvim
    use { 'phaazon/hop.nvim', config = load_config("plugins.configs.hop") }

    -- Leap for visual word jumping (reboot of Lightspeed)
    -- https://github.com/ggandor/leap.nvim
    use {
      'ggandor/leap.nvim',
      config = function() require("leap").add_default_mappings() end
    }

    -- Spooky leap actions
    -- https://github.com/ggandor/leap-spooky.nvim
    use {
      'ggandor/leap-spooky.nvim',
      config = function() require("leap-spooky").setup({}) end
    }

    -- Custom leap plugin
    require"plugins.custom.leap_ast".setup()
    -- Custom OpenAI plugin
    require"plugins.custom.openai_tools".setup()

    -- Venn for drawing diagrams in vim
    -- https://github.com/jbyuki/venn.nvim
    use 'jbyuki/venn.nvim'

    -- Goto preview window
    -- https://github.com/rmagatti/goto-preview
    use {
      'rmagatti/goto-preview',
      config = load_config("plugins.configs.goto-preview")
    }

    -- Git Signs
    -- https://github.com/lewis6991/gitsigns.nvim
    use {
      'lewis6991/gitsigns.nvim',
      config = load_config("plugins.configs.gitsigns")
    }

    -- VIM Move for moving things around
    -- https://github.com/matze/vim-move
    use 'matze/vim-move'

    -- Dial plugin for number increment/decrement
    -- https://github.com/monaqa/dial.nvim
    use { 'monaqa/dial.nvim', config = load_config('plugins.configs.dial') }

    -- Cheatsheet
    -- https://github.com/sudormrfbin/cheatsheet.nvim
    use 'sudormrfbin/cheatsheet.nvim'

    -- https://github.com/nvim-lua/popup.nvim
    use 'nvim-lua/popup.nvim'

    -- Autopairs
    -- https://github.com/windwp/nvim-autopairs
    use {
      'windwp/nvim-autopairs',
      requires = { 'hrsh7th/nvim-cmp' },
      config = load_config("plugins.configs.nvim-autopairs")
    }

    -- Enable more of the rust-analyzer features (e.g. inlay hints)
    -- https://github.com/simrat39/rust-tools.nvim
    use {
      'simrat39/rust-tools.nvim',
      config = load_config("plugins.configs.rust")
    }

    -- Todo comments
    -- https://github.com/folke/todo-comments.nvim
    use {
      'folke/todo-comments.nvim',
      config = function() require("todo-comments").setup({}) end
    }

    -- Better marks
    -- https://github.com/chentoast/marks.nvim
    use { 'chentoast/marks.nvim', config = load_config("plugins.configs.marks") }

    -- Better quickfix list
    -- https://github.com/kevinhwang91/nvim-bqf
    use { 'kevinhwang91/nvim-bqf', ft = 'qf' }

    -- Lua documentation in NeoVim help
    -- https://github.com/nanotee/luv-vimdocs
    -- https://github.com/milisims/nvim-luaref
    use { 'nanotee/luv-vimdocs' }
    use { 'milisims/nvim-luaref' }

    -- Screenwriting with Fountain
    -- https://fountain.io
    -- https://github.com/kblin/vim-fountain
    use { 'kblin/vim-fountain' }

    -- Flow-State reading in neovim
    -- https://github.com/nullchilly/fsread.nvim
    use {
      "nullchilly/fsread.nvim",
      config = function()
        require("core.utils").map("n", "<Leader>cF", "<CMD>FSToggle<CR>",
                                  { desc = "Toggle Flow-State" })
      end
    }

    -- Cellular automata in Neovim
    -- https://github.com/Eandrju/cellular-automaton.nvim
    use {
      'eandrju/cellular-automaton.nvim',
      config = function()
        require("core.utils").map("n", "<Leader>fml",
                                  "<CMD>CellularAutomaton make_it_rain<CR>")
      end
    }

    -- Chat with ChatGPT
    -- https://github.com/terror/chatgpt.nvim
    -- use({ 'terror/chatgpt.nvim', run = 'pip3 install -r requirements.txt' })

    if packer_boostrap then require("packer").sync() end
  end,
  config = { max_jobs = 8 }
})

