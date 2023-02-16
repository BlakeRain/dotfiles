-- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
-- https://github.com/folke/noice.nvim

local function scroll_forward()
  if not require("noice.lsp").scroll(4) then return "<c-f>" end
end

local function scroll_backward()
  if not require("noice.lsp").scroll( -4) then return "<c-b>" end
end

local function redirect()
  require("noice").redirect(vim.fn.getcmdline())
end

local M = {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  },
  keys = {
    { "<S-Enter>",
      redirect,
      mode = "c",
      desc = "Redirect Cmdline" },
    { "<leader>nl",
      function() require("noice").cmd("last") end,
      desc = "Noice Last Message" },
    { "<leader>nh",
      function() require("noice").cmd("history") end,
      desc = "Noice History" },
    { "<leader>na",
      function() require("noice").cmd("all") end,
      desc = "Noice All" },
    { "<c-f>",
      scroll_forward,
      silent = true,
      expr = true,
      desc = "Scroll forward",
      mode = { "i", "n", "s" } },
    { "<c-b>",
      scroll_backward,
      silent = true,
      expr = true,
      desc = "Scroll backward",
      mode = { "i", "n", "s" } },
  },
}

return M
