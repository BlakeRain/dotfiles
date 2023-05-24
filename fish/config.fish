set -x LANG en_GB.UTF-8

if type -q pycrumbs
    abbr -a c pycrumbs
    abbr -a ce pycrumbs exec
end

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Abbreviate 'v' to NeoVIM
    if [ -f /opt/homebrew/bin/nvim -o -f /usr/bin/nvim ]
        abbr -a v nvim
    end

    # Add the GitHub CLI if it exists
    if [ -f /usr/bin/gh ]
        # eval "(gh completion -s fish)"
    end

    # Abbreviate the 'gg' command to 'lazygit'
    if command -v lazygit >/dev/null
        abbr -a gg lazygit
    end

    # Add aliases to relace 'ls' (and similar) to 'exa'
    if command -v exa >/dev/null
        abbr -a l exa
        abbr -a ls exa
        abbr -a ll 'exa -l --git'
        abbr -a lll 'exa -la --git'
    else
        abbr -a l ls
        abbr -a ll 'ls -l'
        abbr -a lll 'ls -la'
    end

    if command -v ranger >/dev/null
        abbr -a r ranger
    end

    # Fish git prompt
    set __fish_git_prompt_showuntrackedfiles yes
    set __fish_git_prompt_showdirtystate yes
    set __fish_git_prompt_showstashstate ''
    set __fish_git_prompt_showupstream none
    set -g fish_prompt_pwd_dir_length 3

    # Set our editor
    setenv EDITOR nvim

    # Ser out OpenAI API key
    setenv OPENAI_API_KEY (cat "$HOME/.openai.secret-key.json" | jq -r '.secretKey')

    # colored man output
    # from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
    setenv LESS_TERMCAP_mb \e'[01;31m' # begin blinking
    setenv LESS_TERMCAP_md \e'[01;38;5;74m' # begin bold
    setenv LESS_TERMCAP_me \e'[0m' # end mode
    setenv LESS_TERMCAP_se \e'[0m' # end standout-mode
    setenv LESS_TERMCAP_so \e'[38;5;246m' # begin standout-mode - info box
    setenv LESS_TERMCAP_ue \e'[0m' # end underline
    setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

    setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
    setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
    setenv FZF_DEFAULT_OPTS '--height 20%'

    # TokyoNight Color Palette: https://github.com/folke/tokyonight.nvim
    set -l foreground c0caf5
    set -l selection 33467c
    set -l comment 565f89
    set -l red f7768e
    set -l orange ff9e64
    set -l yellow e0af68
    set -l green 9ece6a
    set -l purple 9d7cd8
    set -l cyan 7dcfff
    set -l pink bb9af7

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan
    set -g fish_color_keyword $pink
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_error $red
    set -g fish_color_param $purple
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $pink
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
    set -g fish_pager_color_selected_background --background=$selection

    function sugoi_emoti
        set -l EMOTI (sort -R ~/.config/fish/sugoi-emoti | head -n1)
        echo -e " \e[3$(random 1 6)m$EMOTI\e[0m"
    end

    function is_the_internet_on_fire
        host -t txt istheinternetonfire.com | cut -f 2 -d '"' | awk '{gsub(/http/,"\n\nhttp");print}' | awk \
            'NR==1{cmd="fold -s -w 60";print $0|cmd;close(cmd)}NR>1{print}'
    end


    function fish_greeting
        if command -v neofetch >/dev/null
            neofetch
        else
            echo -e (uname -sm | awk -F" " '{print " \\\\e[1mArch     : \\\\e[0;32m"$1" (\\\\e[0;34m"$2"\\\\e[0;32m)\\\\e[0m"}')
            echo -e (uptime | awk -F, '{print $1}' | sed 's/[0-9]\{2\}:[0-9]\{2\} *up //g' | \
              awk '{print " \\\\e[1mUptime   : \\\\e[0;32m"$0"\\\\e[0m"}')
            echo -ne (uname -n | awk '{print " \\\\e[1mHostname : \\\\e[0;32m"$0"\\\\e[0m"}')
            sugoi_emoti
            echo
        end
    end

    function clear_screen
        clear
        fish_greeting
        if [ -d /var/mail/blake ] && mail -e
            echo "You have mail"
        end
    end

    alias cls=clear_screen

    # Tell fish that we want to use VI bindings
    fish_vi_key_bindings
    fish_vi_cursor

    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    set fish_cursor_visual block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursor to an underscore
    set fish_cursor_replace_one underscore

end
