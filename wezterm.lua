local wezterm = require("wezterm")
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
  config.default_prog = { "/usr/bin/tmux" }
else
  config.default_prog = { "/usr/local/bin/tmux" }
end

config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono", { weight = "DemiBold" })
-- config.font = wezterm.font("Atkinson Hyperlegible Mono", { weight = "Regular" })
config.font_size = 13.0

config.hide_tab_bar_if_only_one_tab = true

config.quote_dropped_files = "Posix"

config.initial_cols = 120
config.initial_rows = 50
config.window_background_opacity = 0.9

-- Disable detecting password input as we use tmux
config.detect_password_input = false

config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
return config
