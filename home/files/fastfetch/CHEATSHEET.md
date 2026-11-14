# fastfetch cheat sheet

Quick reference for [fastfetch](https://github.com/fastfetch-cli/fastfetch). All flags
are case-insensitive.

## Everyday

| command | does |
| --- | --- |
| `fastfetch` | run with the default config |
| `fastfetch -c config.jsonc` | pick a config by name or path |
| `fastfetch -c config-compact.jsonc` | compact profile |
| `fastfetch -c config-pokemon.jsonc` | Pokémon profile |
| `fastfetch -c config-v2.jsonc` | v2 profile |
| `fastfetch --pipe` | no colors (good for pipes) |
| `fastfetch -s <structure>` | override module structure for one run |
| `fastfetch --stat` | show ms spent per module |
| `fastfetch -w` / `--watch 2` | refresh every N seconds |

## Discover what's available

| command | does |
| --- | --- |
| `fastfetch --list-modules` | every module name |
| `fastfetch --list-logos` | bundled ASCII logos |
| `fastfetch --print-logos` | preview bundled logos |
| `fastfetch --list-presets` | config presets |
| `fastfetch --print-structure` | default module structure |
| `fastfetch --list-features` | compiled-in features |
| `fastfetch --list-config-paths` | where it looks for configs |
| `fastfetch --list-data-paths` | where it looks for logos/presets |
| `fastfetch --help <module>` | module-specific options, e.g. `--help cpu` |

## Generate / edit configs

```bash
fastfetch --gen-config                 # interactive, writes config.jsonc
fastfetch --gen-config ~/.config/fastfetch/new.jsonc
fastfetch --gen-config-force           # overwrite without asking
```

JSONC accepts `//` comments and trailing commas. The schema line used in these configs:

```jsonc
"$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json"
```

Minimal config skeleton:

```jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": { "padding": { "top": 1 } },
  "display": { "separator": " -> " },
  "modules": ["break", "os", "kernel", "shell", "terminal", "memory", "uptime"]
}
```

## One-off overrides

| flag | does |
| --- | --- |
| `-l, --logo <source>` | logo file/name, or `none` |
| `--logo-type <type>` | how to draw it (see below) |
| `--logo-width <n>` / `--logo-height <n>` | image size in characters |
| `--logo-position <pos>` | `left`, `right`, `top` |
| `--logo-padding <n>` / `--logo-padding-top <n>` | spacing |
| `--separator <str>` | key/value separator |
| `--key-width <n>` | align keys to n columns |
| `--color <color>` | keys + title color |
| `--color-keys` / `--color-title` / `--color-output` | individual colors |
| `--duration-abbreviation` | shorten durations |
| `--size-binary-prefix <enum>` | `b`/`kb`/`kib` style units |
| `--temp-unit <enum>` | `C`, `F`, `K` |
| `--percent-type <n>` | percentage display style |
| `--bar-width <n>` | percentage bar width |
| `--json` | machine-readable output |

## Logo types

| type | notes |
| --- | --- |
| `kitty-direct` | fastest, needs kitty/ghostty/wezterm |
| `kitty` / `kitty-icat` | kitty image protocol |
| `iterm` | iTerm2 inline images |
| `sixel` | sixel terminals (foot, wezterm…) |
| `chafa` | image → text, works anywhere |
| `file` | ANSI text file logo |
| `file-raw` | raw ANSI passthrough — use with `--logo -` |
| `raw` | raw logo data |
| `data` / `data-raw` | inline logo data |
| `none` | no logo |

Convenience shorthands: `--kitty <path>`, `--kitty-direct <path>`, `--sixel <path>`,
`--chafa <path>`, `--file <path>`, `--file-raw <path>`.

## Modules used here

| module | shows |
| --- | --- |
| `title` | `user@host` — `{6}{7}{8}` = user, host, separator |
| `os` | distro |
| `kernel` | kernel version |
| `packages` | package count |
| `shell` | current shell |
| `wm` / `wmtheme` | window manager + theme |
| `icons` / `cursor` / `terminalfont` | desktop details |
| `terminal` | terminal emulator |
| `host` | machine model |
| `cpu` / `gpu` | processor(s) |
| `display` | resolution + refresh |
| `memory` / `swap` | RAM / swap |
| `disk` | disk usage |
| `uptime` | uptime |
| `sound` / `player` / `media` | audio and now playing |
| `battery` | battery level |
| `localip` | local IP |
| `custom` | arbitrary text / ANSI |
| `break` | empty line |

Module config example:

```jsonc
{
  "type": "memory",
  "key": "󰍛 ",
  "keyColor": "magenta",
  "format": "{1} / {2}"          // used / total
},
{
  "type": "kernel",
  "key": "│ ├",
  "keyColor": "yellow"
},
{
  "type": "custom",
  "format": "   \u001b[31m  \u001b[32m  \u001b[33m "
}
```

`title` placeholders: `{1}` user, `{2}` hostname, `{3}` username, `{6}` user,
`{7}` host, `{8}` separator — the config here uses `{6}{7}{8}`.

## Structure syntax

Run just a few modules for one command without editing a config:

```bash
fastfetch -s os:kernel:shell:memory
fastfetch -s os:kernel:break:memory --logo none
fastfetch --structure-disabled gpu:disk
```

## Troubleshooting

**Icons show as boxes / question marks**
Install a Nerd Font and select it in the terminal. Test with `fastfetch -s os` after
changing the font.

**Image logo is missing**
Your terminal probably doesn't support the chosen protocol. Try:

```bash
fastfetch -c config-compact.jsonc --logo-type chafa   # works anywhere
fastfetch -c config-compact.jsonc --kitty-direct ~/.config/fastfetch/fedora.png
```

**Logo is stretched**
Set `--logo-width`/`--logo-height` to match the terminal aspect, or add
`--logo-preserve-aspect-ratio`.

**Pokémon profile is blank**
`pokemon-colorscripts` must be on `PATH`. Check with `command -v pokemon-colorscripts`
and run it alone first.

**Prompt/fetch is slow**
`fastfetch --stat` shows per-module cost. Disable expensive modules (`packages`,
`disk`, `player`) or raise `--processing-timeout`.

**Garbage escape codes in a pipe**
Add `--pipe` (or `--pipe true`).
