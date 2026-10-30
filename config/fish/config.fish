set fish_greeting

pokemon-colorscripts --no-title -s -r | fastfetch \
    -c $HOME/.config/fastfetch/config-pokemon.jsonc \
    --logo-type file-raw \
    --logo-height 10 \
    --logo-width 5 \
    --logo -

#neofetch --off --block_range 0 7
#neofetch
#neofetch --block_range 0 7
# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
end

alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias llt='eza -lah --tree --level=2 --icons'
# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    if set -q __zoxide_loop
        builtin echo "zoxide: infinite loop detected"
        builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
        return 1
    end
    __zoxide_loop=1 __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (builtin count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if test $argc -eq 2 -a $argv[1] = --
        __zoxide_cd -- $argv[2]
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (builtin commandline --current-process --tokenize)
    set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

    if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
    else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
        # If the last argument is empty, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and __zoxide_cd $result
        and builtin commandline --function cancel-commandline repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually
# ~/.config/fish/config.fish):
#
#   zoxide init fish | source
alias c="clear"
# alias c="clear; neofetch --off --block_range 0 7"
# neofetch --config ~/.config/neofetch/config_def.conf
# alias c="neofetch --block_range 0 7"
# alias c="neofetch --kitty ~/Pictures/Nord/unsplash20.png"
# nitch
alias n='nitch'
alias fox='catnip -c ~/.config/catnip/config_fox.toml'
alias fox2='catnip -c ~/.config/catnip/config_fox2.toml'
alias fox3='catnip -c ~/.config/catnip/config_fox3.toml'

# alias ls='lsd -a'
# alias ll='lsd -ahl'
alias icat='kitten icat'
alias cat='catnip'
export LS_COLORS="*.ini=31:*.ttf=36:*.toml=35"

#alias c="clear; neofetch --block_range 0 7"
#export PATH="$"PATH":/home/bluebyt/.local/bin"
set -x PATH $PATH ~/.bin
set -x PATH $PATH ~/.local/bin
set -x PATH $PATH ~/.local/bin/eww
set -x PATH $PATH ~/.local/bin/go/bin/
set -x PATH $PATH ~/.cargo/bin
alias work='$HOME/.bin/cleanup_after_start.sh'
alias pipe='$HOME/Active/color-scripts/color-scripts/./pipes2'
alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
alias play='ncmpcpp'
alias la='exa -a --color=always --group-directories-first' # all files and dirs
#. ~/.config/fish/functions/noti.fish

# Starship theme switcher
function starship-theme
    set -l theme $argv[1]
    set -l theme_dir ~/.config/starship

    if test -f "$theme_dir/starship_$theme.toml"
        set -gx STARSHIP_CONFIG "$theme_dir/starship_$theme.toml"
    else if test -f "$theme_dir/$theme.toml"
        set -gx STARSHIP_CONFIG "$theme_dir/$theme.toml"
    else
        echo "Available themes:"
        ls $theme_dir
        return 1
    end

    echo "Switched Starship theme to: $theme"
    starship init fish | source
end
set -gx STARSHIP_CONFIG ~/.config/starship/jack.toml
fzf --fish | source
starship init fish | source
