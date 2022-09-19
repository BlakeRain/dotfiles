local neo_tree = require("neo-tree")
local utils = require("core.utils")

local M = {}
M.setup = function()
  vim.fn.sign_define("DiagnosticSignError",
                     { text = " ", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DiagnosticSignWarn",
                     { text = " ", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DiagnosticSignInfo",
                     { text = " ", texthl = "DiagnosticSignInfo" })
  vim.fn.sign_define("DiagnosticSignHint",
                     { text = "", texthl = "DiagnosticSignHint" })

  neo_tree.setup({
    close_if_last_window = false,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = { indent_size = 2, padding = 1, with_markers = true },
      name = { trailing_slash = false, use_git_status_colors = true }
    },
    window = {
      position = "left",
      mappings = {
        ["<space>"] = "toggle_node",
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<C-j>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["R"] = "refresh",
        ["a"] = "add",
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy", -- takes text input for destination
        ["m"] = "move", -- takes text input for destination
        ["q"] = "close_window",
        ["o"] = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.fn.system("open " .. vim.fn.fnameescape(path))
        end,
        ["w"] = function(state)
          local node = state.tree:get_node()
          local success, picker = pcall(require, "window-picker")
          if not success then
            print(
              "You'll need to install window-picker to use this command: https://github.com/s1n7ax/nvim-window-picker")
            return
          end
          local picked_window_id = picker.pick_window()
          if picked_window_id then
            vim.api.nvim_set_current_win(picked_window_id)
            vim.cmd("edit " .. vim.fn.fnameescape(node.path))
          end
        end
      }
    },
    filesystem = {
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,
        never_show = { ".DS_Store", "thumbs.db" }
      }
    }
  })

  -- Toggle Neotree file browser.
  utils.map('n', '<leader>v',
            '<cmd>Neotree toggle=true reveal=true position=left<cr>',
            { desc = "Toggle Neotree" })

  -- Close Neotree file browser.
  utils.map('n', '<leader>V', '<cmd>Neotree action=close position=left<cr>',
            { desc = "Close Neotree" })
end

return M
