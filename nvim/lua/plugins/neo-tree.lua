-- File browser
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local M = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  keys = {
    { "<leader>v", "<cmd>Neotree toggle=true reveal=true position=left<cr>", desc = "Toggle neotree" },
    { "<leader>V", "<cmd>Neotree action=close position=left<cr>",            desc = "Close neotree" }
  }
}

function M.init()
  vim.g.neo_tree_remove_legacy_commands = 1
  if vim.fn.argc() == 1 then
    local stat = vim.loop.fs_stat(vim.fn.argv(0))
    if stat and stat.type == "directory" then
      require("neo-tree")
    end
  end
end

function M.config()
  vim.fn.sign_define("DiagnosticSignError",
    { text = " ", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DiagnosticSignWarn",
    { text = " ", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DiagnosticSignInfo",
    { text = " ", texthl = "DiagnosticSignInfo" })
  vim.fn.sign_define("DiagnosticSignHint",
    { text = "", texthl = "DiagnosticSignHint" })

  require("neo-tree").setup({
    default_component_configs = {
      indent = { indent_size = 2, padding = 1, with_markers = true },
      name = { trailing_slash = false, use_git_status_colors = true },
      icon = {
        folder_empty = "󰜌",
        folder_empty_open = "󰜌",
      },
      git_status = {
        symbols = {
          renamed  = "󰁕",
          unstaged = "󰄱",
        },
      },
    },
    document_symbols = {
      kinds = {
        File = { icon = "󰈙", hl = "Tag" },
        Namespace = { icon = "󰌗", hl = "Include" },
        Package = { icon = "󰏖", hl = "Label" },
        Class = { icon = "󰌗", hl = "Include" },
        Property = { icon = "󰆧", hl = "@property" },
        Enum = { icon = "󰒻", hl = "@number" },
        Function = { icon = "󰊕", hl = "Function" },
        String = { icon = "󰀬", hl = "String" },
        Number = { icon = "󰎠", hl = "Number" },
        Array = { icon = "󰅪", hl = "Type" },
        Object = { icon = "󰅩", hl = "Type" },
        Key = { icon = "󰌋", hl = "" },
        Struct = { icon = "󰌗", hl = "Type" },
        Operator = { icon = "󰆕", hl = "Operator" },
        TypeParameter = { icon = "󰊄", hl = "Type" },
        StaticMethod = { icon = '󰠄 ', hl = 'Function' },
      }
    },
    source_selector = {
      winbar = true,
      statusline = false,
      sources = {
        { source = "filesystem", display_name = " 󰉓 Files " },
        { source = "git_status", display_name = " 󰊢 Git " },
      }
    },
    close_if_last_window = false,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    window = {
      position = "left",
      mappings = {
        ["<space>"] = "none",
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
      follow_current_file = true,
      filtered_items = {
        visible = true,
        never_show = { ".DS_Store", "thumbs.db" }
      }
    }
  })
end

return M
