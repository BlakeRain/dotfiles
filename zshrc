autoload -U colors && colors
setopt autocd extendedglob nomatch menucomplete
setopt interactivecomments
stty stop undef
unsetopt beep
bindkey -v

SAVEHIST=10000

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
load_share "zsh-autosuggestions"
load_share "zsh-syntax-highlighting"

