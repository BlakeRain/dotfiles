---@diagnostic disable
local xplr = xplr -- The globally exposed configuration to be overridden.
---@diagnostic enable

version = "0.21.2"

local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path .. ";"
    .. xpm_path .. "/?.lua;"
    .. xpm_path .. "/?/init.lua"

os.execute(
  string.format(
    "[ -e '%s' ] || git clone '%s' '%s'",
    xpm_path,
    xpm_url,
    xpm_path
  )
)

require("xpm").setup({
  plugins = {
    -- Let xpm manage itself
    'dtomvan/xpm.xplr',
    { name = 'sayanarijit/fzf.xplr' },
    'gitlab:hartan/web-devicons.xplr',
  },
  auto_install = true,
  auto_cleanup = true,
})

-- Enable mouse scrolling
xplr.config.general.enable_mouse = true

-- Hide hidden files by default
xplr.config.general.show_hidden = false

xplr.config.node_types.directory.meta.icon = "󰉓"

xplr.fn.builtin.fmt_general_table_row_cols_0 = function(m)
  local r = ""
  if m.is_before_focus then
    r = r .. " -"
  else
    r = r .. "  "
  end

  r = r .. m.relative_index
  return r
end

xplr.config.modes.builtin.default.key_bindings.on_key.v = {
  help = "View with Bat",
  messages = {
    {
      BashExec0 = [===[
        bat "${XPLR_FOCUS_PATH:?}"
      ]===]
    }
  }
}

xplr.config.modes.builtin.default.key_bindings.on_key.m = {
  help = "Bookmark (session)",
  messages = {
    {
      BashExecSilently0 = [===[
        PTH="${XPLR_FOCUS_PATH:?}"
        PTH_ESC=$(printf %q "$PTH")
        if echo "${PTH:?}" >> "${XPLR_SESSION_PATH:?}/bookmarks"; then
          "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC added to session bookmarks"
        else
          "$XPLR" -m 'LogError: %q' "Failed to bookmark $PTH_ESC"
        fi
      ]===]
    }
  }
}

xplr.config.modes.builtin.default.key_bindings.on_key.M = {
  help = "Bookmark (global)",
  messages = {
    {
      BashExecSilently0 = [===[
        PTH="${XPLR_FOCUS_PATH:?}"
        PTH_ESC=$(printf %q "$PTH")
        if echo "${PTH:?}" >> "${HOME}/cs/dotfiles/xplr/bookmarks"; then
          "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC added to global bookmarks"
        else
          "$XPLR" -m 'LogError: %q' "Failed to bookmark $PTH_ESC"
        fi
      ]===]
    }
  }
}

xplr.config.modes.builtin.default.key_bindings.on_key["`"] = {
  help = "Go to bookmarks",
  messages = {
    {
      BashExec0 = [===[
        PTH=$(cat "${HOME:?}/cs/dotfiles/xplr/bookmarks" "${XPLR_SESSION_PATH:?}/bookmarks" | while read line; do eval echo "$line"; done | fzf --no-sort)
        PTH_ESC=$(printf %q "$PTH")
        if [ "$PTH" ]; then
          "$XPLR" -m 'FocusPath: %q' "$PTH"
        fi
      ]===]
    }
  }
}


return {}
