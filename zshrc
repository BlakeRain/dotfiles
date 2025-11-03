autoload -U colors && colors

# Set the ZSH cache directory and make sure that it exists
ZSH_CACHE_DIR="$HOME/.cache/zsh"
if [ ! -d "$ZSH_CACHE_DIR" ]; then
  mkdir -p "$ZSH_CACHE_DIR"
fi

# Load all the stock functions
autoload -U compaudit compinit zercompile
autoload -Uz vcs_info

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

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Use tmux (v3.2+) popup feature
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

autoload -U +X bashcompinit && bashcompinit

[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# bindkey -v

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

function _log_note() {
  echo -e "\e[1m\e[36mNOTE:\e[0m" "$@"
}

function _log_warn() {
  echo -e "\e[1m\e[1;33mWARN:\e[0m" "$@"
}

if [[ ! -d "$HOME/.local/share/zsh" ]]; then
  _log_note "Creating '$HOME/.local/share/zsh' directory"
  mkdir -p "$HOME/.local/share/zsh"
fi

if [[ ! -d "$HOME/.local/share/zsh/fzf-tab" ]]; then
  if command -v git >/dev/null; then
    _log_note "Cloning fzf-tab into '$HOME/.local/share/zsh/fzf-tab'"
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$HOME/.local/share/zsh/fzf-tab"
  else
    _log_warn "No 'git' command available; unable to clone fzf-tab"
  fi
fi

if [[ -d "$HOME/.local/share/zsh/fzf-tab" ]]; then
  source "$HOME/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh"
else
  _log_warn "fzf-tab not available"
fi

function greeting() {
  local load=$(uptime | sed 's/.*load av.*: \(.*\)/\1/')
  local procs=$(ps -caxm | tail -n +2 | wc -l | awk '{ print $1 }')
  local rss=$(ps aux | awk '{ sum += $6 } END { printf("%.2f MiB", sum / 1024.0) }')

  local ifconfig_script='
    /^[a-zA-Z0-9]+:/ {
      iface = substr($1, 0, length($1) - 1)
    }

    /^[ \t]+inet / {
      printf("(\x1b[95m%s\x1b[0m):%s\n", iface, $2)
    }'

  echo -e "\x1b[96mload:\x1b[0m $load" "/ \x1b[96mprocs:\x1b[0m $procs" "/ \x1b[96mrss:\x1b[0m $rss"
  echo -e "\x1b[96mip:\x1b[0m" "$(ifconfig | awk "$ifconfig_script" | tr '\n' ' ' | sed 's/ $//' | sed 's^ ^ / ^g')"
}

function clear_screen() {
  clear
  greeting
  if [ -d /var/mail/blake ] && mail -e; then
    echo "You have mail"
  fi
}

alias cls=clear_screen

if [ "$(uname)" = "Darwin" ]; then
  function _clipboard_copy() {
    pbcopy
  }
else
  function _clipboard_copy() {
    xclip -selection clipboard
  }
fi

function copydir() {
  pwd | tr -d "\r\n" | _clipboard_copy
}

function copyfile() {
  [[ "$#" != 1 ]] && return 1
  local file_to_copy=$1
  cat $file_to_copy | _clipboard_copy
}

function copybuffer() {
  local buf=""
  if test -z $BUFFER; then
    buf=$(fc -ln -1)
  else
    buf=$BUFFER
  fi

  printf "%s" "$buf" | _clipboard_copy
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

# If we have a `~/.local/bin` directory, then add it to the path
if [[ -d $HOME/.local/bin ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d $HOME/.cargo/bin ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
else
  _log_warn "No Rust Cargo bin directory found"
fi

# Add the GitHub CLI if it exists
if command -v gh >/dev/null; then
  eval "$(gh completion -s zsh)"
else
  _log_warn "No GitHub CLI found"
fi

# Add aliases to relace 'ls' (and similar) to 'exa'
if command -v eza >/dev/null; then
  alias exa=eza
  alias l=eza
  alias ls=eza
elif command -v exa >/dev/null; then
  alias l=exa
  alias ls=exa
else
  alias l=ls
fi

if ! command -v nvim >/dev/null; then
  _log_warn "No Neovim found"
fi

if ! command -v yazi >/dev/null; then
  _log_warn "No yazi found; visit https://yazi-rs.github.io/docs/installation"
fi

if ! command -v fzf >/dev/null; then
  _log_note "Need to install fzf; visit https://github.com/junegunn/fzf"
fi

if command -v ag >/dev/null; then
  export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
else
  _log_note "Need to install ag; visit https://github.com/ggreer/the_silver_searcher"
fi

if command -v rg >/dev/null; then
  function rgv() {
    rg -n "$@" | fzf --height 40 --layout=reverse --border --preview "$HOME/cs/dotfiles/zsh/_rgv_preview.sh"' {}' | cut -d':' -f1,2 | xargs -n 1 "$HOME/cs/dotfiles/zsh/_rgv_edit.sh"
  }
else
  _log_note "Need to install rg; visit https://github.com/BurntSushi/ripgrep"
fi

if [[ -f $HOME/.opam/opam-init/init.zsh ]]; then
  source $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null
fi

# FZF auto-completion and key bindings
if [ -d /opt/homebrew/opt/fzf/shell ]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
elif [ -d /usr/share/fzf ]; then
  source "/usr/share/fzf/completion.zsh" 2> /dev/null
  source "/usr/share/fzf/key-bindings.zsh"
elif [ -d /usr/share/doc/fzf/examples ]; then
  source "/usr/share/doc/fzf/examples/completion.zsh" 2> /dev/null
  source "/usr/share/doc/fzf/examples/key-bindings.zsh"
else
  _log_warn "Missing zsh fzf completion and key-bindings"
fi

export EDITOR=nvim
export PAGER=less
export LESS=-R

export BROWSER=firefox
if [ "$(uname)" = "Darwin" ]; then
  export BROWSER="open -a 'Firefox Developer Edition'"
fi

greeting

function load_dotfile() {
  if [ -f $HOME/cs/dotfiles/zsh/$1.zsh ]; then
    source $HOME/cs/dotfiles/zsh/$1.zsh
  elif [ -f $HOME/.config/zsh/$1.zsh ]; then
    source $HOME/.config/zsh/$1.zsh
  else
    _log_warn "Unable to find '$1.zsh' (in Synology dotfiles or ~/.config/zsh)"
  fi
}

function load_share() {
  if [ -f /opt/homebrew/share/$1/$1.zsh ]; then
    source /opt/homebrew/share/$1/$1.zsh
  elif [ -f /usr/share/$1/$1.zsh ]; then
    source /usr/share/$1/$1.zsh
  elif [ -f /usr/share/zsh/plugins/$1/$1.zsh ]; then
    source /usr/share/zsh/plugins/$1/$1.zsh
  else
    _log_warn "Unable to find '$1' (in Homebrew or /usr/share)"
  fi
}

load_dotfile "1password"
load_dotfile "p10k"
load_dotfile "dir-history"
load_dotfile "dir-persist"
load_dotfile "git"
load_dotfile "misc"
load_dotfile "completions/eksctl"

function zvm_config() {
  ZVM_VI_HIGHLIGHT_BACKGROUND="#45475B"
}

function append-last-word { ((++CURSOR)); zle insert-last-word; }
zle -N append-last-word
bindkey -M vicmd '\e.' append-last-word
bindkey -M viins '\e.' insert-last-word

if [ "$(uname)" = "Darwin" ]; then
  load_dotfile "osx"
fi

load_share "zsh-autosuggestions"
load_share "zsh-syntax-highlighting"

if command -v atuin >/dev/null; then
  eval "$(atuin init zsh)"
else
  _log_note "Need to install atuin; visit https://atuin.sh/docs/ and follow QuickStart"
  _log_note "(Authentication credentials are in password manager)"
fi

if [[ -f "$HOME/.ghcup/env" ]]; then
  source "$HOME/.ghcup/env"
fi

# See https://github.com/nvm-sh/nvm#installation-and-update
if [[ -z "$NVM_DIR" ]]; then
  export NVM_DIR="$HOME/.nvm"
fi

function activate_nvm() {
  if [[ -f "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  else
    _log_warn "NVM not installed or nvm.sh not found in \$NVM_DIR"
  fi
}

if [[ -f "$NVIM_DIR/bash_completion" ]]; then
  source "$NVIM_DIR/bash_completion"
fi

if command -v kubctl >/dev/null; then
  source <(kubectl completion zsh)
fi

if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

precmd() { vcs_info }

setopt prompt_subst
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%F{#fab387}%b%f '
PS1='%B%F{#74c7ec}%n@%m%b%f ${vcs_info_msg_0_}%F{#89b4fa}%1~%f %% '
# RPROMPT='%F{#7f849c}%D{%Y-%m-%d} %*%f'

export GPG_TTY=$(tty)

export LEDGER_FILE="$HOME/cs/hledger/main.journal"

if [[ -d "/opt/homebrew/opt/sqlite/bin" ]]; then
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
fi

PATH="/Users/blakerain/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/blakerain/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/blakerain/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/blakerain/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/blakerain/perl5"; export PERL_MM_OPT;

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/blakerain/.lmstudio/bin"

# IntelliShell
export INTELLI_HOME="/Users/blakerain/Library/Application Support/org.IntelliShell.Intelli-Shell"
# export INTELLI_SEARCH_HOTKEY='^@'
# export INTELLI_VARIABLE_HOTKEY='^l'
# export INTELLI_BOOKMARK_HOTKEY='^b'
# export INTELLI_FIX_HOTKEY='^x'
# export INTELLI_SKIP_ESC_BIND=0
# alias is="intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
eval "$(intelli-shell init zsh)"
