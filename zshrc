autoload -U colors && colors

# Set the ZSH cache directory and make sure that it exists
ZSH_CACHE_DIR="$HOME/.cache/zsh"
if [ ! -d "$ZSH_CACHE_DIR" ]; then
  mkdir -p "$ZSH_CACHE_DIR"
fi

# Load all the stock functions
autoload -U compaudit compinit zercompile

compinit -u

zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol

setopt auto_cd
setopt auto_menu         # show completion menu on successive tab press
setopt auto_pushd
setopt always_to_end
setopt complete_in_word
setopt long_list_jobs
setopt pushd_ignore_dups
setopt pushdminus
setopt interactivecomments
stty stop undef
unsetopt beep

bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

autoload -U +X bashcompinit && bashcompinit

[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

bindkey -e

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
fi

# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
fi

# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char

# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M emacs "^[3;5~" delete-char
fi

# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word

# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

bindkey '^W' kill-region
bindkey '^I' complete-word

function greeting() {
  if command -v neofetch >/dev/null; then
    neofetch
  fi
}

function clear_screen() {
  clear
  greeting
  if [ -d /var/mail/blake ] && mail -e; then
    echo "You have mail"
  fi
}

alias cls=clear_screen

function copydir() {
  pwd | tr -d "\r\n" | pbcopy
}

function copyfile() {
  [[ "$#" != 1 ]] && return 1
  local file_to_copy=$1
  cat $file_to_copy | pbcopy
}

function copybuffer() {
  local buf=""
  if test -z $BUFFER; then
    buf=$(fc -ln -1)
  else
    buf=$BUFFER
  fi

  printf "%s" "$buf" | pbcopy
}

zle -N copybuffer
bindkey '^O' copybuffer

function google() {
  if [[ $# -lt 1 ]]; then
    open "https://www.google.co.uk/"
    return
  fi

  url="https://www.google.co.uk/search?q="
  while [[ $# -gt 0 ]]; do
    url="${url}$1+"
    shift
  done

  url="${url%?}"
  open "$url"
}

# Add the GitHub CLI if it exists
if command -v gh >/dev/null; then
  eval "$(gh completion -s zsh)"
fi

# Abbreviate the 'gg' command to 'lazygit'
if command -v lazygit >/dev/null; then
    alias gg=lazygit
fi

# Add aliases to relace 'ls' (and similar) to 'exa'
if command -v exa >/dev/null; then
    alias l=exa
    alias ls=exa
    alias ll="exa -l --git"
    alias lll="exa -la --git"
else
    alias l=ls
    alias ll="ls -l"
    alias lll="ls -la"
fi

# See if `xplr` is knocking around
if command -v xplr >/dev/null; then
  alias x=xplr

  # Change to a directory selected with `xplr`
  alias xcd='cd $(xplr --print-pwd-as-result)'
else
  alias x=ls
fi

if command -v ranger >/dev/null; then
    alias r=ranger
fi

if [ -f /opt/homebrew/bin/nvim -o -f /usr/bin/nvim ]; then
  alias v=nvim
fi

# FZF auto-completion and key bindings
if [ -d /opt/homebrew/opt/fzf/shell ]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
fi

export EDITOR=nvim
export PAGER=less
export LESS=-R

if command -v jq >/dev/null; then
  if [ -f ~/.openai.secret-key.json ]; then
    export OPENAI_API_KEY=$(cat "$HOME/.openai.secret-key.json" | jq -r ".secretKey")
  else
    echo "OpenAI secret key not found; OPENAI_API_KEY will not be available"
  fi
else
  echo "Need to install jq; OPENAI_API_KEY will not be available"
fi

greeting

if [ -d /opt/homebrew/opt/powerlevel10k ]; then
  source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
elif [ -d /usr/share/powerlevel10k ]; then
  source /usr/share/powerlevel10k/powerlevel10k.zsh-theme
else
  echo "Need to install powerline10k for zsh theme"
fi

function load_dotfile() {
  if [ -f $HOME/cs/dotfiles/zsh/$1.zsh ]; then
    source $HOME/cs/dotfiles/zsh/$1.zsh
  elif [ -f $HOME/.config/zsh/$1.zsh ]; then
    source $HOME/.config/zsh/$1.zsh
  else
    echo "Unable to find '$1.zsh' (in Synology dotfiles or ~/.config/zsh)"
  fi
}

function load_share() {
  if [ -f /opt/homebrew/share/$1/$1.zsh ]; then
    source /opt/homebrew/share/$1/$1.zsh
  elif [ -f /usr/share/$1/$1.zsh ]; then
    source /usr/share/$1/$1.zsh
  else
    echo "Unable to find '$1' (in Homebrew or /usr/share)"
  fi
}

load_dotfile "1password"
load_dotfile "p10k"
load_dotfile "dir-history"
load_dotfile "dir-persist"
load_dotfile "osx"
load_dotfile "auto-notify"
load_dotfile "misc"
load_share "zsh-autosuggestions"
load_share "zsh-syntax-highlighting"
