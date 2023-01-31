local wezterm = require("wezterm")

local keys = {
}

for i = 97, 122 do
  local ch = string.char(i)

  table.insert(keys, {
    key = ch,
    mods = "ALT",
    action = wezterm.action.SendString("\x1b" .. ch)
  })

  table.insert(keys, {
    key = ch,
    mods = "ALT|SHIFT",
    action = wezterm.action.SendString("\x1b" .. string.upper(ch))
  })
end

for i = 0, 9 do
  local ch = string.char(i + 48)

  local action
  if i == 3 then
    action = wezterm.action.SendString("#")
  else
    action = wezterm.action.SendString("\x1b" .. ch)
  end

  table.insert(keys, {
    key = ch,
    mods = "ALT",
    action = action
  })
end

return {
  font = wezterm.font("JetBrainsMono Nerd Font Mono"),
  font_size = 14.0,
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = { "/opt/homebrew/bin/fish", "--login", "-c", "tmux" },
  set_environment_variables = {
    TERM = "xterm-256color",
  },
  color_scheme = "tokyonight",
  window_decorations = "RESIZE",
  background = {
    { source = { Color = "#1a1b26" }, opacity = 0.96, width = "100%", height = "100%" }
  },
  initial_cols = 150,
  initial_rows = 80,
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = true,
  keys = keys,
}
