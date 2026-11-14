# fish config

My personal [fish](https://fishshell.com/) setup — a Pokémon fetch on startup, zoxide
jumping, `eza` listings, a yazi wrapper, and the Starship prompt.

![fish preview](preview/acats.png)

Tested with fish `4.6.0` on Fedora 44, kitty, and a Nerd Font.

## Files

| file | what |
| --- | --- |
| `config.fish` | the main config — startup fetch, aliases, zoxide, starship, paths |
| `conf.d/rustup.fish` | sources the Cargo environment |
| `functions/y.fish` | `yazi` wrapper that changes the shell's directory on exit |
| `completions/` | place for custom completions (empty right now) |
| `fish_variables` | fish universal variables — machine-specific, **git-ignored** |
| `preview/acats.png` | screenshot used in this README |

## What's in here

### Startup

The fish greeting is disabled (`set fish_greeting`), then a random shiny Pokémon is
piped into fastfetch:

```fish
pokemon-colorscripts --no-title -s -r | fastfetch \
    -c $HOME/.config/fastfetch/config-pokemon.jsonc \
    --logo-type file-raw \
    --logo-height 10 \
    --logo-width 5 \
    --logo -
```

### Prompt

```fish
set -gx STARSHIP_CONFIG ~/.config/starship/jack.toml
starship init fish | source
fzf --fish | source
```

`starship-theme <name>` switches `STARSHIP_CONFIG` for the current session — see the
[starship-config repo](https://github.com/Shroudmoa/starship-config).

### Aliases

| alias | runs | notes |
| --- | --- | --- |
| `l` / `lt` | `eza --tree --level=2 --icons` | tree view |
| `ll` / `llt` | `eza -lah --tree --level=2 --icons` | long + tree |
| `ls` | `eza --icons --group-directories-first` | replaces `ls` |
| `la` | `exa -a --color=always --group-directories-first` | **last definition wins**, needs `exa` |
| `c` | `cd ..` | up one |
| `d` | `clear` | |
| `g` | `glow` | markdown renderer |
| `z` / `zz` | zoxide jump | `yy` is an alias for `z` |
| `zi` / `x` | zoxide interactive | `x` is an alias for `zi` |
| `y` | yazi wrapper | `functions/y.fish` |
| `icat` | `kitten icat` | kitty image preview |
| `max` | `ssh-list` | [ssh-list](https://github.com/akinoiro/ssh-list) |
| `play` | `ncmpcpp` | MPD client |
| `n` | `nitch` | small fetch |
| `work` | `~/.bin/cleanup_after_start.sh` | local script |
| `pipe` | `~/Active/color-scripts/color-scripts/pipes2` | local script |
| `unlock` | `sudo rm /var/lib/pacman/db.lck` | pacman-specific, harmless elsewhere |

### Environment

```fish
set -gx EDITOR nvim
export LS_COLORS="*.ini=31:*.ttf=36:*.toml=35"

set -x PATH $PATH ~/.bin
set -x PATH $PATH ~/.local/bin
set -x PATH $PATH ~/.local/bin/eww
set -x PATH $PATH ~/.local/bin/go/bin/
set -x PATH $PATH ~/.cargo/bin
```

Path entries that don't exist are harmless.

### Zoxide

The full generated zoxide block is inlined in `config.fish` — `z <keywords>` jumps to
frecency-ranked directories, `zi` opens the interactive picker. `cd` keeps working
normally.

## Dependencies

### Required

| dependency | why |
| --- | --- |
| [fish](https://fishshell.com/) ≥ 3.x (tested `4.6.0`) | the shell |
| [starship](https://starship.rs/) | prompt (`starship init fish`) |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | startup fetch |
| [pokemon-colorscripts](https://gitlab.com/phoneybadger/pokemon-colorscripts) | Pokémon art for the fetch |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z` / `zi` |
| [eza](https://github.com/eza-community/eza) | `ls`/`l`/`ll`/`lt` aliases |
| [fzf](https://github.com/junegunn/fzf) | `fzf --fish` integration |
| [yazi](https://github.com/sxyazi/yazi) | `y` file manager |
| [glow](https://github.com/charmbracelet/glow) | `g` markdown viewer |
| [neovim](https://neovim.io/) | `$EDITOR` |
| A [Nerd Font](https://www.nerdfonts.com/) | icons in eza/starship/fastfetch |

### Optional

| dependency | why |
| --- | --- |
| [kitty](https://sw.kovidgoyal.net/kitty/) | `icat` (`kitten icat`) |
| [ssh-list](https://github.com/akinoiro/ssh-list) | `max` |
| [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp) + MPD | `play` |
| [nitch](https://github.com/unxsh/nitch) | `n` |
| Rust / Cargo | `conf.d/rustup.fish`, cargo paths |
| `exa` | only if you want the current `la` alias to work |

The `work` and `pipe` aliases point at scripts that live outside this repo.

## Install (Fedora)

```bash
sudo dnf install fish starship fastfetch zoxide eza fzf yazi glow neovim kitty \
    ncmpcpp mpd
```

Extra tools:

```bash
# Rust / Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# ssh-list
cargo install ssh-list

# pokemon-colorscripts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts && sudo ./install.sh
```

### This config + its companions

```bash
git clone https://github.com/Shroudmoa/fish-config      ~/.config/fish
git clone https://github.com/Shroudmoa/starship-config  ~/.config/starship
git clone https://github.com/Shroudmoa/fastfetch-config ~/.config/fastfetch
```

Open a new shell, or:

```fish
source ~/.config/fish/config.fish
```

## Notes

- `fish_variables` is git-ignored on purpose — it stores per-machine universal variables.
- `la` is defined twice in `config.fish`; the later `exa` version wins. Change that line
  to `eza -a --icons --group-directories-first` if you don't have `exa`.
- `unlock` is a pacman (Arch) convenience. It does nothing useful on Fedora.
- The Pokémon fetch runs on every shell start. If that gets in the way of scripts,
  wrap it in `if status is-interactive`.

## See also

- [CHEATSHEET.md](CHEATSHEET.md) — aliases, functions, fish commands, troubleshooting
- [starship-config](https://github.com/Shroudmoa/starship-config)
- [fastfetch-config](https://github.com/Shroudmoa/fastfetch-config)
