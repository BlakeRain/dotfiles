#!/usr/bin/env bash

declare -A THEME=(
    ["background"]="#1A1B26"
    ["foreground"]="#a9b1d6"
    ["black"]="#414868"
    ["blue"]="#7aa2f7"
    ["cyan"]="#7dcfff"
    ["green"]="#73daca"
    ["magenta"]="#bb9af7"
    ["red"]="#f7768e"
    ["white"]="#c0caf5"
    ["yellow"]="#e0af68"

    ["bblack"]="#394264"
    ["bblue"]="#7aa2f7"
    ["bcyan"]="#7dcfff"
    ["bgreen"]="#41a6b5"
    ["bmagenta"]="#bb9af7"
    ["bred"]="#ff9e64"
    ["bwhite"]="#787c99"
    ["byellow"]="#e0af68"
  )

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"

tmux set -g mode-style "fg=${THEME[bgreen]},bg=${THEME[bblack]}"
tmux set -g message-style "bg=${THEME[blue]},fg=${THEME[background]}"
tmux set -g message-command-style "fg=${THEME[white]},bg=${THEME[black]}"

tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[blue]}"
tmux set -g pane-border-status off

tmux set -g status-style bg="${THEME[background]}"

hostname=$(hostname -s)
tmux set -g status-left "#[fg=${THEME[bblack]},bg=${THEME[blue]},bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S $hostname #[bg=${THEME[background]},fg=${THEME[blue]}]"
tmux set -g window-status-format "$RESET#[fg=${THEME[foreground]}]  ${RESET}#I #W "
tmux set -g window-status-current-format "$RESET#[fg=${THEME[green]},bg=${THEME[bblack]}]  #[fg=${THEME[foreground]},bold,nodim]#I #W "

date_and_time="$RESET#[fg=${THEME[blue]},bg=${THEME[bblack]}]#[fg=${THEME[bblack]},bg=${THEME[blue]},bold] %Y-%m-%d %H:%M "
tmux set -g status-right "#[fg=${THEME[bblack]},bg=default]#[fg=blue,bg=${THEME[bblack]}]  #{pane_current_path} $date_and_time"
tmux set -g window-status-separator ""
