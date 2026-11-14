# fastfetch config

My personal [fastfetch](https://github.com/fastfetch-cli/fastfetch) configs — four presets, Nerd Font icons, and optional Pokémon logos on shell startup.

![fastfetch preview](preview/acats.png)

Built on Fedora 44 with fish, kitty and a Nerd Font.

## Files

| file | what |
| --- | --- |
| `config.jsonc` | full system info — the default profile |
| `config-compact.jsonc` | compact layout with the Fedora logo (kitty-direct) |
| `config-pokemon.jsonc` | short layout, logo piped in from `pokemon-colorscripts` |
| `config-v2.jsonc` | alternate full layout with a different grouping |
| `fedora.png` | image logo used by `config-compact.jsonc` |
| `preview/acats.png` | screenshot used in this README |

All configs use the JSONC schema, so `//` comments and trailing commas are allowed.

## Dependencies

| dependency | why |
| --- | --- |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) ≥ 2.x (tested on `2.68.1`) | the fetcher itself |
| A [Nerd Font](https://www.nerdfonts.com/) (e.g. JetBrainsMono Nerd Font) | icons and glyphs in keys/output |
| A terminal with the kitty graphics protocol (kitty, ghostty, wezterm) | renders `fedora.png` — other terminals fall back to ASCII |
| [pokemon-colorscripts](https://gitlab.com/phoneybadger/pokemon-colorscripts) *(optional)* | Pokémon logo for `config-pokemon.jsonc` |
| [fish](https://fishshell.com/) *(optional)* | startup integration |

## Install

### Fedora

```bash
sudo dnf install fastfetch
```

If your repos are behind, use the COPR:

```bash
sudo dnf copr enable deajan/fastfetch
sudo dnf install fastfetch
```

### Nerd Font

```bash
# any Nerd Font works; this is the one I use
mkdir -p ~/.local/share/fonts
# download JetBrainsMono Nerd Font from nerdfonts.com, unzip into the folder
fc-cache -fv
```

Then set the font in your terminal.

### Pokémon (optional)

```bash
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts
sudo ./install.sh
```

### This config

```bash
git clone https://github.com/Shroudmoa/fastfetch-config ~/.config/fastfetch
```

## Usage

```bash
fastfetch                              # config.jsonc
fastfetch -c config-compact.jsonc      # compact + Fedora logo
fastfetch -c config-pokemon.jsonc      # pokemon layout
fastfetch -c config-v2.jsonc           # v2 layout
```

`fastfetch` looks in `~/.config/fastfetch/` automatically, so `-c <name>` resolves
against that directory.

### Shell startup (fish)

From my `config.fish`:

```fish
set fish_greeting

pokemon-colorscripts --no-title -s -r | fastfetch \
    -c $HOME/.config/fastfetch/config-pokemon.jsonc \
    --logo-type file-raw \
    --logo-height 10 \
    --logo-width 5 \
    --logo -
```

`pokemon-colorscripts` prints a random shiny Pokémon as ANSI, and fastfetch reads it
from `--logo -` (`file-raw`) so the character art and system info share one block.

## Picking a logo

`--logo-type` decides how the image is drawn:

| type | works in |
| --- | --- |
| `kitty-direct` | kitty, ghostty, wezterm |
| `kitty` / `kitty-icat` | kitty and compatible terminals |
| `sixel` | sixel-capable terminals (foot, wezterm, …) |
| `chafa` | any terminal, converts the image to colored text |
| `file` / `file-raw` | raw ANSI text files (this is what the Pokémon pipe uses) |
| `none` | disable the logo |

If the logo looks stretched or missing, see [CHEATSHEET.md](CHEATSHEET.md#troubleshooting).

## Credit

- Presets and module lists built on the [fastfetch docs](https://github.com/fastfetch-cli/fastfetch/wiki).
- Pokémon art from [pokemon-colorscripts](https://gitlab.com/phoneybadger/pokemon-colorscripts).

## See also

- [CHEATSHEET.md](CHEATSHEET.md) — commands, modules, logo types, troubleshooting
- [starship-config](https://github.com/Shroudmoa/starship-config) — the prompt that goes with it
