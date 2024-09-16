-- File browser
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local M = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  keys = {
    {
      "<leader>v",
      "<cmd>Neotree toggle=true reveal=true position=left<cr>",
      desc = "Toggle neotree",
    },
    {
      "<leader>V",
      "<cmd>Neotree current<cr>",
      desc = "Neotree netrw style"
    }
  }
}

-- function M.init()
--   local open_netrw = false
--   if vim.fn.argc() == 1 then
--     local stat = vim.loop.fs_stat(vim.fn.argv(0))
--     if stat and stat.type == "directory" then
--       open_netrw = true
--     end
--   elseif vim.fn.argc() == 0 then
--     open_netrw = true
--   end
--
--   if open_netrw then
--     vim.defer_fn(function()
--       vim.cmd("Neotree current")
--     end, 10)
--   end
-- end

function M.config()
  require("neo-tree").setup({
    default_component_configs = {
      container = { enable_character_fade = true },
      indent = { indent_size = 2, padding = 1, with_markers = true },
      name = { trailing_slash = false, use_git_status_colors = true },
      icon = {
        folder_empty = "󰜌",
        folder_empty_open = "󰜌",
      },
      git_status = {
        symbols = {
          -- Change type
          added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
          modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
          deleted   = "✖", -- this can only be used in the git_status source
          renamed   = "󰁕", -- this can only be used in the git_status source
          -- Status type
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        }
      },
      diagnostics = {
        symbols = {
          error = "",
          warn = "",
          info = "",
          hint = "󰌵"
        }
      }
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
        ["l"] = "open",
        ["L"] = "open_split",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["C"] = "close_node",
        ["h"] = "close_node",
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
      hijack_netrw_behavior = "open_current",
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = false
      },
      filtered_items = {
        visible = true,
        never_show = { ".DS_Store", "thumbs.db" }
      },
      group_empty_dirs = true,
      -- scan_mode = "deep"
    }
  })
end

return M
