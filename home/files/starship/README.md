# starship config

My personal [Starship](https://starship.rs/) prompt collection — four themes, all
built around Nerd Font glyphs and true color.

![starship preview](preview/acats.png)

Tested with fish 4.6 and Starship 1.24 on Fedora 44.

## Themes

| file | look |
| --- | --- |
| `jack.toml` | Rose Pine pill segments: user, directory, git, languages, clock — **active by default** |
| `starship.toml` | blocky black/red/green powerline-style `PROMPT` bar |
| `blue.toml` | Catppuccin Mocha boxed prompt (by [a3chron](https://github.com/a3chron)) |
| `jetpack.toml` | the dense [Jetpack preset](https://starship.rs/presets/jetpack) with a right prompt |

`preview/acats.png` is the shared screenshot used across my dotfiles.

## Dependencies

| dependency | why |
| --- | --- |
| [starship](https://starship.rs/) ≥ 1.x (tested on `1.24.2`) | renders the prompt |
| A [Nerd Font](https://www.nerdfonts.com/) (e.g. JetBrainsMono Nerd Font) | icons, custom glyphs, powerline separators |
| A true-color terminal | `bg:`/`fg:` hex colors and gradients |
| [fish](https://fishshell.com/) ≥ 3.x (tested on `4.6.0`) | shell integration; `init fish` |
| Language toolchains *(optional)* | modules only appear when the toolchain is present |
| `git` *(optional)* | branch/status/metrics modules |

The language segments in `jack.toml` (`c`, `elixir`, `elm`, `golang`, `haskell`,
`java`, `julia`, `nodejs`, `nim`, `rust`, `scala`, `conda`, `python`) are harmless
when a toolchain is missing — Starship simply hides them.

## Install

### Fedora

```bash
sudo dnf install starship
```

Or the upstream script:

```bash
curl -sS https://starship.rs/install.sh | sh
```

### Nerd Font

Install any Nerd Font into `~/.local/share/fonts`, run `fc-cache -fv`, then select it
in the terminal. This config assumes the font has the full Nerd Font glyph set.

### This config

```bash
git clone https://github.com/Shroudmoa/starship-config ~/.config/starship
```

## Shell setup (fish)

Add to `~/.config/fish/config.fish`:

```fish
set -gx STARSHIP_CONFIG ~/.config/starship/jack.toml
starship init fish | source
```

`STARSHIP_CONFIG` is optional — without it Starship uses `~/.config/starship.toml`.
Setting it explicitly is what selects a theme here.

## Theme switching

`config.fish` ships a small helper:

```fish
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
```

Usage:

```fish
starship-theme jack      # ~/.config/starship/jack.toml
starship-theme blue      # ~/.config/starship/blue.toml
starship-theme jetpack   # ~/.config/starship/jetpack.toml
starship-theme starship  # ~/.config/starship/starship.toml
```

Persist a choice by editing the `STARSHIP_CONFIG` line in `config.fish`.

## Credit

- `blue.toml` is based on the Catppuccin Mocha prompt by
  [a3chron](https://github.com/a3chron).
- `jetpack.toml` follows the official
  [Jetpack preset](https://starship.rs/presets/jetpack).
- Everything else follows the [Starship docs](https://starship.rs/config/).

## See also

- [CHEATSHEET.md](CHEATSHEET.md) — commands, modules, styles, troubleshooting
- [fastfetch-config](https://github.com/Shroudmoa/fastfetch-config) — the fetch that runs above it
