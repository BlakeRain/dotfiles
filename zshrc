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
else
  echo "Need to install powerline10k for zsh theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [ -f $HOME/cs/dotfiles/zsh/p10k.zsh ]; then
  source $HOME/cs/dotfiles/zsh/p10k.zsh
else
  echo "Unable to find powerline10k configuration"
fi

if [ -d /opt/homebrew/share/zsh-autosuggestions ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  echo "Need to install zsh-autosuggestions"
fi

if [ -d /opt/homebrew/share/zsh-syntax-highlighting ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
  echo "Need to install zsh-syntax-highlighting"
fi

if [ -f $HOME/cs/dotfiles/zsh/dir-history.zsh ]; then
  source $HOME/cs/dotfiles/zsh/dir-history.zsh
else
  echo "Unable to find dir-history.zsh (Synology dotfiles)"
fi

if [ -f $HOME/cs/dotfiles/zsh/dir-persist.zsh ]; then
  source $HOME/cs/dotfiles/zsh/dir-persist.zsh
else
  echo "Unable to find dir-persist.zsh (Syngology dotfiles)"
fi

if [ -f $HOME/cs/dotfiles/zsh/osx.zsh ]; then
  source $HOME/cs/dotfiles/zsh/osx.zsh
else
  echo "Unable to find osx.zsh (Synology dotfiles)"
fi

if [ -f $HOME/cs/dotfiles/zsh/auto-notify.zsh ]; then
  source $HOME/cs/dotfiles/zsh/auto-notify.zsh
else
  echo "Unable to find auto-notify.zsh (Synology dotfiles)"
fi

# if type brew &>/dev/null; then
#   FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
#   autoload -Uz compinit
#   compinit
# fi
