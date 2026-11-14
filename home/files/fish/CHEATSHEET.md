# fish cheat sheet

Quick reference for this fish setup. See [config.fish](config.fish) for the source.

## Daily commands

| command | does |
| --- | --- |
| `source ~/.config/fish/config.fish` | reload config |
| `exec fish` | restart the shell cleanly |
| `fish_config` | open the web-based config UI |
| `fish_config prompt` | pick a stock prompt (will replace starship) |
| `funced <name>` | edit a function interactively |
| `funcsave <name>` | save an interactive function to `functions/` |
| `functions` | list defined functions |
| `abbr --list` / `abbr -a name expansion` | list / add abbreviations |
| `fish_add_path ~/bin` | add to `PATH` permanently |
| `fish_update_completions` | regenerate man-page completions |
| `history` / `history search <text>` | history |
| `math '2+2'` | arithmetic |
| `string` | string manipulation helpers |
| `set -S <var>` | show a variable and its scope |

## Aliases in this config

| alias | expands to |
| --- | --- |
| `ls` | `eza --icons --group-directories-first` |
| `l`, `lt` | `eza --tree --level=2 --icons` |
| `ll` | `eza -lah --icons --group-directories-first --git` |
| `llt` | `eza -lah --tree --level=2 --icons` |
| `la` | `exa -a --color=always --group-directories-first` |
| `c` | `cd ..` |
| `d` | `clear` |
| `g` | `glow` |
| `z`, `yy` | zoxide jump |
| `zi`, `x` | zoxide interactive |
| `icat` | `kitten icat` |
| `max` | `ssh-list` |
| `play` | `ncmpcpp` |
| `n` | `nitch` |
| `work` | `~/.bin/cleanup_after_start.sh` |
| `pipe` | `~/Active/color-scripts/color-scripts/pipes2` |
| `unlock` | `sudo rm /var/lib/pacman/db.lck` |

Aliases are just functions, so they show up in `functions` and can be inspected with
`functions la`.

## Functions

### `y` — yazi with directory tracking

`functions/y.fish` runs yazi, then `cd`s to the last directory you were in when you quit:

```fish
y              # open yazi here
y ~/Downloads  # open yazi in a folder
```

### zoxide

| command | does |
| --- | --- |
| `z foo` | jump to the best frecency match |
| `z foo bar` | match multiple keywords |
| `zi` | interactive picker (fzf) |
| `z -` | jump to previous directory |
| `zoxide query foo` | print the match without jumping |
| `zoxide edit` | remove broken entries |
| `zoxide add <dir>` | add manually |

`cd` still behaves normally; zoxide only hooks it to record visits.

### `starship-theme <name>`

```fish
starship-theme jack       # ~/.config/starship/jack.toml
starship-theme blue
starship-theme jetpack
starship-theme starship   # ~/.config/starship/starship.toml
```

It sets `STARSHIP_CONFIG` and re-runs `starship init fish | source`. Without a valid
name it lists the available themes.

## Environment

| variable | value |
| --- | --- |
| `EDITOR` | `nvim` |
| `STARSHIP_CONFIG` | `~/.config/starship/jack.toml` |
| `LS_COLORS` | custom `.ini`/`.ttf`/`.toml` colors |
| `PATH` | adds `~/.bin`, `~/.local/bin`, `~/.local/bin/eww`, `~/.local/bin/go/bin`, `~/.cargo/bin` |
| `fish_greeting` | empty — greeting disabled |

Check values:

```fish
echo $EDITOR
echo $STARSHIP_CONFIG
string join \n $PATH
```

Set one for the session:

```fish
set -gx EDITOR nvim
```

## Startup chain

1. `conf.d/rustup.fish` — loads Cargo env.
2. `config.fish`
   - clears the greeting
   - runs `pokemon-colorscripts | fastfetch` (Pokémon + system info)
   - inlines the zoxide init
   - defines aliases, `EDITOR`, `LS_COLORS`, `PATH`
   - defines `starship-theme`
   - sets `STARSHIP_CONFIG`, starts starship and fzf
3. `functions/y.fish` is lazy-loaded the first time `y` runs.

## Handy fish syntax

| syntax | meaning |
| --- | --- |
| `set -gx VAR value` | global exported variable |
| `set -l VAR value` | local variable |
| `set -e VAR` | erase variable |
| `set -S VAR` | show scope/value |
| `command foo` | bypass aliases/functions |
| `builtin cd` | call the builtin explicitly |
| `status is-interactive` | true in an interactive shell |
| `test -f file; and echo yes` | conditionals use `and` / `or` |
| `for x in a b; ...; end` | loops |
| `$argv[1]` | first argument |
| `string split , $var` | split a string |
| `commandline` | inspect/edit the current command line |

## Troubleshooting

**Alias or function not found after editing**
Reload: `source ~/.config/fish/config.fish`. If it's in `functions/`, fish picks it up
automatically in new shells.

**`la` fails with `Unknown command: exa`**
`la` is redefined later in `config.fish` to use `exa`, which isn't installed. Install
`exa`, or edit that line to `eza -a --icons --group-directories-first`.

**No Pokémon / no fetch on startup**
Check each piece:

```fish
command -v pokemon-colorscripts
command -v fastfetch
pokemon-colorscripts --no-title -s -r | head
```

The fastfetch config must exist at `~/.config/fastfetch/config-pokemon.jsonc`.

**Prompt is plain / no starship**
Run `starship prompt`. If that works, re-init:

```fish
starship init fish | source
```

Also make sure `STARSHIP_CONFIG` points at an existing file.

**Icons show as boxes**
Install a Nerd Font and select it in the terminal; then restart the terminal.

**Startup feels slow**
The Pokémon fetch runs every shell start. Time it:

```fish
time pokemon-colorscripts --no-title -s -r >/dev/null
```

To keep it out of scripts, wrap the block:

```fish
if status is-interactive
    pokemon-colorscripts --no-title -s -r | fastfetch ...
end
```

**Cargo/rustup not found**
`conf.d/rustup.fish` sources `~/.cargo/env.fish`. Reinstall rustup if that file is
missing, or add `~/.cargo/bin` to `PATH` (already done in `config.fish`).

**`fish_variables` keeps changing**
It's machine-local and git-ignored. That's expected — don't commit it.
