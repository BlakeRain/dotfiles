# Configuration for NeoVim

This directory contains my configuration for NeoVim. Pretty much all of the configuration is done in Lua. I use Folke's
[lazy.nvim] as my package manager. The plugins are loaded from the `lua/plugins` directory by the Lazy package manager.
Most plugins have their own module, but some are grouped together (such as `nvim-cmp` and it's extensions). Some of the
smaller plugins are also recorded directly in the `lua/plugins/init.lua` file.
