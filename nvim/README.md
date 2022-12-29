# Configuration for NeoVim

This directory contains my configuration for NeoVim. Pretty much all of the configuration is done in Lua. I use Folke's
[lazy.nvim] as my package manager.

## Custom Plugins

There are some custom plugins that I've written, most of which have been superseded by much better plugins, but I still
use mine for now.

| Plugin                                                            | Synopsys                                 |
|-------------------------------------------------------------------|------------------------------------------|
| [`chatgpt.lua`](/blob/main/nvim/lua/custom/chatgpt.lua)           | A ChatGPT implementation using GPT-3 API |
| [`openai_tools.lua`](/blob/main/nvim/lua/custom/openai_tools.lua) | OpenAI tools (describe code, etc).       |
| [`leap_ast.lua`](/blob/main/nvim/lua/custom/leap_ast.lua)         | Leap extension using treesitter AST      |

[lazy.nvim]: https://github.com/folke/lazy.nvim

