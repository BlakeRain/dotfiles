# Configuration for NeoVim

This directory contains my configuration for NeoVim. Pretty much all of the configuration is done in Lua. I use Folke's
[lazy.nvim] as my package manager.

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
