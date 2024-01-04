#
# ~/.bashrc
#

# Add 256-color terminal support
#export TERM=xterm-256color

# Don't put duplicate lines or lines starting with space in the
# history
HISTCONTROL=ignoreboth

# Append to the history file rather than overwriting it
shopt -s histappend

# Check the window size after each command and, if necessary, update
# the values of LINES and COLUMNS
shopt -s checkwinsize

# Set our command recall to the last 2000 commands (see bash(1))
HISTSIZE=2000
HISTFILESIZE=5000

# Make less more friendly for non-text input files (see lesspipe(1))
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set the variable identifying the chroot we're in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Set the default prompt, which we will overwrite with the result of pureline
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm, set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

# Enable colour support of ls and also add some handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls="ls --color=auto"
  alias grep="grep --color=auto"
  alias fgrep="fgrep --color=auto"
  alias egrep="egrep --color=auto"
fi

# If we're on OSX, then we can add colors by default
if [ "$(uname -s)" = "Darwin" ]; then
  alias ls="ls -G"
fi

# Colour GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01:32:locus=01:quote=01'

# Add some aliases for 'ls' command
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# Add some aliases for emacs
alias et='emacsclient -t'
alias em='emacsclient -c -n'

# Add an 'alert' alias for long running commands that will display a
# message on the desktop. This should be used like:
#
#     long_running_command; alert
#
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Add in the magic bash programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Add ~/.local/bin to our PATH (stuff installed by the likes of
# Haskell stack end up in this directory).
PATH=~/.local/bin:$PATH

# If we're on OSX, then add brew to our path
if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# Set the GPG TTY
export GPG_TTY=$(tty)

# Set our editor to micro (if we have it), falling back to nano
if [ -x "$(command -v micro)" ]; then
  export EDITOR=micro
else
  export EDITOR=nano
fi

# Add alias for lazy git
alias gg=lazygit

# If we have a user yarn binary directory, add it to path
if [ -d "$HOME/.yarn/bin" ]; then
  PATH="$HOME/.yarn/bin:$PATH"
fi

# Add the .cargo/bin directory to PATH if it exists
if [ -d "$HOME/.cargo/bin" ] ; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

# Add the /snap/bin directory to PATH if it exists
if [ -d "/snap/bin" ]; then
  PATH="/snap/bin:$PATH"
fi

# Make sure that the Python stuff is in the PATH on OSX
if [ -d $HOME/Library/Python/3.9/bin ]; then
  PATH="$HOME/Library/Python/3.9/bin:$PATH"
fi

# Set the VCPKG root
export VCPKG_ROOT="$HOME/dev/foss/vcpkg"

if [ -f ~/dev/foss/vcpkg/scripts/vcpkg_completion.bash ]; then
  source /home/blake/dev/foss/vcpkg/scripts/vcpkg_completion.bash
fi

# See if we have teleport installed
if [ -f ~/.local/bin/teleport.sh ]; then
  source ~/.local/bin/teleport.sh
fi

# Source the pycrumbs completion (if we find it), and add the aliases
# for the commands
if [ -f ~/dev/personal/pycrumbs/pycrumbs-completion.bash ]; then
  source ~/dev/personal/pycrumbs/pycrumbs-completion.bash
  alias c=pycrumbs
  alias ce='pycrumbs exec'
  complete -F _pycrumbs_completion c
  complete -F _pycrumbs_exec_completion ce
fi

# Add in AWS completion, if we have the AWS CLI completer
if [ -x "$(command -v aws_completer)" ]; then
  complete -C '$(which aws_completer)' aws
fi

# If we have the git completion script, then invoke it
if [ -f ~/cs/dotfiles/git-completion.bash ]; then
  source ~/cs/dotfiles/git-completion.bash
fi

# Add in the GitHub application completion
if [ -f /usr/bin/gh ]; then
  eval "$(gh completion -s bash)"
fi

. "$HOME/.cargo/env"

# Add a completion on OSX for makefiles
if [[ "$(uname -s)" == Darwin* ]]; then
  _makefile_targets() {
    make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u
  }

  _makefile_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=()
    if [[ $COMP_CWORD -eq 1 ]]; then
      if [[ -z $cur ]]; then
        COMPREPLY+=( $(_makefile_targets) )
      else
        COMPREPLY+=( $(_makefile_targets | grep "^$cur") )
      fi
    fi
  }

  complete -F _makefile_completion make
fi

# Add a shortcut that simplies the use of 'xclip'
cb() {
  local _scs_col="\e[0;32m"; local _wrn_col='\e[1;31m'; local _trn_col='\e[0;33m'

  # Check that xsel is installed
  if ! type xsel > /dev/null 2>&1; then
    echo -e "$wrn_col""You must have the 'xsel' program installed.\e[0m"
  # Check user is not root (root doesn't have access to the user's xorg server)
  elif [[ "$USER" == "root" ]]; then
    echo -e "$wrn_col""Must be regular user (not root) to copy to the clipboard.\e[0m"
  else
    # If no tty, data should be available on stdin
    if ! [[ "$( tty )" == /dev/* ]]; then
      input="$(< /dev/stdin)"
    # Otherwise, fetch the input from the parameters
    else
      input="$*"
    fi

    if [ -z "$input" ]; then # If there is no input, print the usage message
      echo "Copies a string to the clipboard."
      echo "Usage: cb <string>"
      echo "       echo string | cb"
    else
      # Copy input to the clipboard
      echo -n "$input" | xsel -ib
      # Truncate text for status
      if [ ${#input} -gt 80 ]; then input="$(echo $input | cut -c1-80)$_trn_col...\e[0m"; fi
      # Print the status
      echo -e "$_scs_col""Copied to clipboard:\e[0m $input"
    fi
  fi
}

# Copy contents of a file (using the 'cb' function above)
function cbf() { cat "$1" | cb; }

# Copy current working directory
alias cbwd="pwd | cb"

# Copy most recent command in bash history
alias cbhs="cat $HISTFILE | tail -n 1 | cb"

# Alias to the RFC script
alias rfc="$HOME/cs/scripts/rfc.sh"

# Add the godir functionality
source "$HOME/cs/scripts/godir.sh"

# Add a function that changes the window title to the current dir
function set_title() {
  echo -ne "\033]0;$(pwd | sed 's:\([^/]\)[^/]*/:\1/:g')\007"
}

function _prompt() {
  local RESULT=$?
  local DIR
  DIR=$(pwd | sed 's:\([^/]\)[^/]*/:\1/:g')

  local TERM_FG_DEFAULT=$'\e[39m'
  local TERM_BG_DEFAULT=$'\e[49m'

  local TERM_DATE_BG=$'\e[48;5;250m'
  local TERM_DATE_FG=$'\e[30m'
  local TERM_DATE_CC=$'\e[38;5;250m'

  local TERM_HOST_BG=$'\e[48;5;119m'
  local TERM_HOST_FG=$'\e[30m'
  local TERM_HOST_CC=$'\e[38;5;119m'

  local TERM_DATE_TO_HOST="$TERM_HOST_BG$TERM_DATE_CC$TERM_HOST_FG"

  local TERM_PATH_BG=$'\e[48;5;69m'
  local TERM_PATH_FG=$'\e[30m'
  local TERM_PATH_CC=$'\e[38;5;69m'

  local TERM_HOST_TO_PATH="$TERM_PATH_BG$TERM_HOST_CC$TERM_PATH_FG"

  local TERM_GIT_BG=$'\e[48;5;208m'
  local TERM_GIT_FG=$'\e[30m'
  local TERM_GIT_CC=$'\e[38;5;208m'
  local TERM_GIT_BEHIND="↓"
  local TERM_GIT_AHEAD="↑"
  local TERM_GIT_CHANGES=" ✚ "
  local TERM_GIT_BRANCH=" "

  local TERM_PATH_TO_GIT="$TERM_GIT_BG$TERM_PATH_CC$TERM_GIT_FG"

  local TERM_ERR_BG=$'\e[41m'
  local TERM_ERR_FG=$'\e[97m'
  local TERM_ERR_CC=$'\e[31m'
  local TERM_ERR_FLAG="⚑ "

  local TERM_GIT_TO_ERR="$TERM_ERR_BG$TERM_GIT_CC$TERM_ERR_FG"
  local TERM_GIT_TO_DEF="$TERM_BG_DEFAULT$TERM_GIT_CC$TERM_FG_DEFAULT"
  local TERM_PATH_TO_ERR="$TERM_ERR_BG$TERM_PATH_CC$TERM_ERR_FG"
  local TERM_PATH_TO_DEF="$TERM_BG_DEFAULT$TERM_PATH_CC$TERM_FG_DEFAULT"
  local TERM_ERR_TO_DEF="$TERM_BG_DEFAULT$TERM_ERR_CC$TERM_FG_DEFAULT"

  local TERM_PROMPT_BG=$'\e[48;5;240m'
  local TERM_PROMPT_FG=$'\e[37m'
  local TERM_PROMPT_CC=$'\e[38;5;240m'

  local TERM_PROMPT_TO_DEF="$TERM_BG_DEFAULT$TERM_PROMPT_CC$TERM_FG_DEFAULT"
  local TERM_PROMPT_STR="$TERM_PROMPT_BG$TERM_PROMPT_FG $ $TERM_PROMPT_TO_DEF"

  if [[ $(tput colors) -lt 256 ]]; then
    TERM_DATE_BG=$'\e[47m'
    TERM_DATE_FG=$'\e[30m'

    TERM_HOST_BG=$'\e[42m'
    TERM_HOST_FG=$'\e[30m'

    TERM_DATE_TO_HOST="$TERM_HOST_BG$TERM_HOST_FG"

    TERM_PATH_BG=$'\e[104m'
    TERM_PATH_FG=$'\e[30m'

    TERM_HOST_TO_PATH="$TERM_PATH_BG$TERM_PATH_FG"

    TERM_GIT_BG=$'\e[43m'
    TERM_GIT_FG=$'\e[30m'
    TERM_GIT_BEHIND=" v"
    TERM_GIT_AHEAD=" ^"
    TERM_GIT_CHANGES="+"
    TERM_GIT_BRANCH=""

    TERM_PATH_TO_GIT="$TERM_GIT_BG$TERM_GIT_FG"

    TERM_ERR_BG=$'\e[101m'
    TERM_ERR_FG=$'\e[30m'
    TERM_ERR_FLAG=""

    TERM_GIT_TO_ERR="$TERM_ERR_BG$TERM_ERR_FG"
    TERM_GIT_TO_DEF="$TERM_BG_DEFAULT$TERM_FG_DEFAULT"
    TERM_PATH_TO_ERR="$TERM_ERR_BG$TERM_ERR_FG"
    TERM_PATH_TO_DEF="$TERM_BG_DEFAULT$TERM_FG_DEFAULT"
    TERM_ERR_TO_DEF="$TERM_BG_DEFAULT$TERM_FG_DEFAULT"

    TERM_PROMPT_BG=$'\e[100m'
    TERM_PROMPT_FG=$'\e[37m'

    TERM_PROMPT_TO_DEF="$TERM_BG_DEFAULT$TERM_FG_DEFAULT"
    TERM_PROMPT_STR="$TERM_PROMPT_TO_DEF$"
  fi

  printf "$TERM_DATE_BG$TERM_DATE_FG %s " "$(date '+%H:%M:%S')"
  printf "$TERM_DATE_TO_HOST %s@%s " "$(whoami)" "$(hostname)"
  printf "$TERM_HOST_TO_PATH %s " "$DIR"

  local ERR_TRANSITION="$TERM_PATH_TO_ERR"
  local DEF_TRANSITION="$TERM_PATH_TO_DEF"

  if [ -d .git ] && [ -f /usr/bin/git ]; then
    local GIT_HEAD GIT_COUNT GIT_BEHIND GIT_AHEAD GIT_CHANGES

    GIT_HEAD=$(git rev-parse --abbrev-ref HEAD)
    GIT_COUNT=$(git rev-list --left-right --count origin/$GIT_HEAD...$GIT_HEAD)
    GIT_BEHIND=$(echo "$GIT_COUNT" | awk '{print $1}')
    GIT_AHEAD=$(echo "$GIT_COUNT" | awk '{print $2}')
    GIT_CHANGES=$(git status -s | wc -l)

    local GIT_BEHIND_STR=""
    if [[ $GIT_BEHIND -gt 0 ]]; then
      GIT_BEHIND_STR="$TERM_GIT_BEHIND$GIT_BEHIND"
    fi

    local GIT_AHEAD_STR=""
    if [[ $GIT_AHEAD -gt 0 ]]; then
      GIT_AHEAD_STR="$TERM_GIT_AHEAD$GIT_AHEAD"
    fi

    local GIT_CHANGES_STR=""
    if [[ $GIT_CHANGES -gt 0 ]]; then
      GIT_CHANGES_STR=" $TERM_GIT_CHANGES$GIT_CHANGES"
    fi

    printf "$TERM_PATH_TO_GIT $TERM_GIT_BRANCH%s%s%s%s " "$(git rev-parse --abbrev-ref HEAD)" "$GIT_BEHIND_STR" "$GIT_AHEAD_STR" "$GIT_CHANGES_STR"
    ERR_TRANSITION="$TERM_GIT_TO_ERR"
    DEF_TRANSITION="$TERM_GIT_TO_DEF"
  fi

  if [[ $RESULT -ne 0 ]]; then
    printf "$ERR_TRANSITION %i $TERM_ERR_FLAG$TERM_ERR_TO_DEF" $RESULT
  else
    echo -ne "$DEF_TRANSITION"
  fi

  echo -ne "\n$TERM_PROMPT_STR "
}

# We only do the rest of this if we're running an interactive shell
if [[ $- =~ .*i.* ]]; then

  trap 'set_title' DEBUG

  #PS1='$(_prompt)'

  # Make sure that we have 'fortune' and 'cowsay'
  if [ -x "$(command -v fortune)" ] && [ -x "$(command -v cowsay)" ] && [ -x "$(command -v lolcat)" ]; then
    FORTUNES_DIR=$HOME/cs/dotfiles/fortunes/$(uname -s)
    if [ -d $FORTUNES_DIR ]; then
      fortune $(find $FORTUNES_DIR -type f '!' -name '*.*') | cowsay -f hellokitty -n | lolcat
    fi
    echo
  fi

  if [[ "$(uname -s)" == Linux* ]]; then
    # Write out some hackernews headlines
    $HOME/cs/scripts/headlines.sh
    alias headlines=$HOME/cs/scripts/headlines.sh
  fi

  # Add a blank line
  echo

  # HSTR configuration
  if [ -f /usr/bin/hstr -o -f /opt/homebrew/bin/hstr ]; then
    alias hh=hstr
    export HSTR_CONFIG=hicolor
    shopt -s histappend
    export HISTCONTROL=ignorespace
    export HISTFILESIZE=10000
    export HISTSIZE=${HISTFILESIZE}
    export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
    if [[ $- =~ .*i.* ]]; then
      bind '"\C-r": "\C-a hstr -- \C-j"'
      bind '"\C-xk": "\C-a hstr -k \C-j"';
    fi
  fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
