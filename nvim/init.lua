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
    -- install = { colorscheme = { "catppuccin-mocha" } },
    checker = { enabled = false },
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

vim.api.nvim_create_user_command("NeogitStart", function(args)
  vim.defer_fn(function()
    require("neogit").open()

    vim.defer_fn(function()
      local buffers = vim.api.nvim_list_bufs()
      local buffer
      for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_name(buf):match("NeogitStatus") then
          buffer = buf
          break
        end
      end

      if not buffer then
        vim.notify("Failed to find Neogit buffer", vim.log.levels.ERROR)
        return
      end

      vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        buffer = buffer,
        callback = function()
          vim.defer_fn(function()
            vim.cmd(":q")
          end, 150)
        end
      })
    end, 150)
  end, 150)
end, { nargs = 0 })

require("keymaps")

-- Some of my custom plugins.
require("custom.jump_ast").setup()
require("custom.openai_tools").setup()
require("custom.chatgpt").setup()
require("custom.mark_signs").setup()
