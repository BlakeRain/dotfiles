# Configuration for NeoVim

This directory contains my configuration for NeoVim. Pretty much all of the configuration is done in Lua. I use Folke's
[lazy.nvim] as my package manager. The plugins are loaded from the `lua/plugins` directory by the Lazy package manager.
Most plugins have their own module, but some are grouped together (such as `nvim-cmp` and it's extensions). Some of the
smaller plugins are also recorded directly in the `lua/plugins/init.lua` file.

## Custom Plugins

There are some custom plugins that I've written, most of which have been superseded by much better plugins, but I still
use mine for now.

| Plugin             | Synopsys                                 |
| ------------------ | ---------------------------------------- |
| [chatgpt.lua]      | A ChatGPT implementation using GPT-3 API |
| [openai_tools.lua] | OpenAI tools (describe code, etc).       |
| [leap_ast.lua]     | Leap extension using treesitter AST      |

[lazy.nvim]: https://github.com/folke/lazy.nvim
[chatgpt.lua]: https://github.com/BlakeRain/dotfiles/blob/main/nvim/lua/custom/chatgpt.lua
[openai_tools.lua]: https://github.com/BlakeRain/dotfiles/blob/main/nvim/lua/custom/openai_tools.lua
[leap_ast.lua]: https://github.com/BlakeRain/dotfiles/blob/main/nvim/lua/custom/leap_ast.lua
