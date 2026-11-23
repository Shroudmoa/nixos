# Server fish config.
# Derived from home/files/fish/config.fish, but stripped of the desktop bits
# (DISPLAY=:99, niri/xwayland aliases, wireshark, kitten, pacman helpers, ...).
set fish_greeting

# --- paths --------------------------------------------------------------------
fish_add_path $HOME/.bin $HOME/.local/bin $HOME/.cargo/bin

# --- editor / pager ------------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# --- prompt -------------------------------------------------------------------
set -gx STARSHIP_CONFIG $HOME/.config/starship/starship.toml

# --- colors -------------------------------------------------------------------
set -gx LS_COLORS "*.ini=31:*.ttf=36:*.toml=35"

# --- aliases ------------------------------------------------------------------
alias l='eza --tree --level=2 --icons'
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias llt='eza -lah --tree --level=2 --icons'
alias c='cd ..'
alias d='clear'
alias g='glow'

# Server-relevant reminder: `y` (yazi) and the age-* helpers come from
# ~/.config/fish/functions, which is linked from the shared dotfiles.

# --- integrations -------------------------------------------------------------
fzf --fish | source
starship init fish | source
zoxide init fish | source
