# Configuration for NeoVim

This directory contains my configuration for NeoVim. Pretty much all of the configuration is done in Lua. This `lua`
directory contains a number of files that should be `required` from an `init.lua` in the Lua configuration file.

```lua
-- ~/.config/nvim/init.lua

-- Load globals
require('globals')

-- Load options
require('options')

-- Keymaps
require('keymaps')

-- Load plugins
require('plugins.init')
```
