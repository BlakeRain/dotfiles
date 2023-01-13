require("options")

-- Bootstrap our package manager (folke/lazy.nvim).
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazy_path,
  })
end

-- If we ended up with lazy being present, then set up our plugins.
vim.opt.runtimepath:prepend(lazy_path)
local have_lazy, lazy = pcall(require, "lazy")
if have_lazy then
  -- Setup Lazy to load our plugins from the 'plugins' directory (see nvim/lua/plugins).
  lazy.setup("plugins", {
    defaults = { lazy = true },
    lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = true },
    diff = {
      cmd = "terminal_git",
    },
    performance = {
      cache = {
        enabled = true,
      },
    }
  })
end

require("keymaps")

-- Some of my custom plugins.
require("custom.leap_ast").setup()
require("custom.openai_tools").setup()
require("custom.chatgpt").setup()
