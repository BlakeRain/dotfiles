hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
  hs.reload()
end)

hs.hotkey.bind({ "ctrl", "alt" }, "T", function()
  hs.osascript.applescript(
  "if application \"WezTerm\" is running then\n  Do Shell Script \"/Applications/WezTerm.app/Contents/MacOS/wezterm-gui\"\nelse\n  tell application \"WezTerm\" to activate\nend if")
end)

function reloadConfig(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end

  if doReload then
    hs.reload()
  end
end

local reloadWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

hs.alert.show("Config loaded")
