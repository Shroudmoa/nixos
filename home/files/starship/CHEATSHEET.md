# starship cheat sheet

Quick reference for [Starship](https://starship.rs/). Config lives in
`~/.config/starship.toml` by default; this setup points at
`~/.config/starship/<theme>.toml` via `STARSHIP_CONFIG`.

## Shell integration

| shell | line |
| --- | --- |
| fish | `starship init fish \| source` |
| bash | `eval "$(starship init bash)"` |
| zsh | `eval "$(starship init zsh)"` |
| nushell | `mkdir ~/.cache/starship; starship init nu \| save -f ~/.cache/starship/init.nu` |
| powershell | `Invoke-Expression (&starship init powershell)` |

Reload fish after editing: `source ~/.config/fish/config.fish` or open a new shell.

## Commands

| command | does |
| --- | --- |
| `starship prompt` | print the current prompt |
| `starship explain` | list the modules currently showing and why |
| `starship timings` | how long each active module takes |
| `starship toggle <module>` | enable/disable a module in the config |
| `starship module <name>` | print one module (e.g. `starship module directory`) |
| `starship print-config` | the computed config, with defaults filled in |
| `starship config` | open the config in `$EDITOR` |
| `starship preset` | list presets |
| `starship preset <name> -o file.toml` | write a preset to a file |
| `starship completions fish` | fish completions |
| `starship session` | new random session key |
| `starship bug-report` | pre-filled issue with diagnostics |

## This repo

| file | theme |
| --- | --- |
| `jack.toml` | Rose Pine pills (default) |
| `starship.toml` | blocky black/red/green bar |
| `blue.toml` | Catppuccin Mocha box |
| `jetpack.toml` | Jetpack preset |

```fish
starship-theme jack        # switch in the current session
echo $STARSHIP_CONFIG      # confirm what is loaded
```

## Config basics

| setting | meaning |
| --- | --- |
| `format` | left prompt; `$module` or `($module)$other` |
| `right_format` | right-aligned side of the line |
| `palette` | named palette; define with `[palettes.name]` |
| `add_newline` | blank line before the prompt |
| `scan_timeout` | ms to scan the directory before giving up |
| `command_timeout` | ms a module may take before being skipped |
| `continuation_prompt` | prompt used on wrapped lines |

### Styles

Styles are a space-separated list:

```
"bold italic fg:blue bg:#1e1e2e"
```

Colors: named (`red`, `bright-black`), hex (`#89b4fa`), or palette keys.
Keys: `bold`, `italic`, `underline`, `dimmed`, `inverted`, `blink`, `hidden`.
Use `bg:transparent` / `none` to clear.

### Palettes

```toml
palette = "rose-pine"

[palettes.rose-pine]
overlay = '#26233a'
love = '#eb6f92'
gold = '#f6c177'
iris = '#c4a7e7'
```

Then reference them as `fg:iris`, `bg:overlay`.

## Common modules

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold fg:blue"

[git_branch]
format = "[ $branch ]($style)"
style = "bg:overlay fg:foam"
symbol = " "

[git_status]
format = '([$all_status$ahead_behind]($style))'
style = "bg:overlay fg:love"

[cmd_duration]
min_time = 500
format = "[ $duration ]($style)"

[time]
disabled = false
time_format = "%I:%M%P"
format = "[ $time ]($style)"

[username]
show_always = true
format = "[ $user ]($style)"

[hostname]
ssh_only = false
format = "[ $hostname ]($style)"

[fill]
symbol = " "

[memory_usage]
disabled = false
threshold = -1
format = "[$ram_pct]($style)"
```

Disable a module with `disabled = true` in its table.

## Format strings

| token | meaning |
| --- | --- |
| `$module` | insert module |
| `($module)` | optional — hidden when the module is empty |
| `[$text]($style)` | styled text |
| `\n` | new line |
| `$fill` | spacer that pushes the rest to the right |
| `${count}` / `$version` | module variables |
| `$all` | every module in default order |

Conditional example:

```toml
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$fill\
$cmd_duration\
$time\
$line_break\
$character"""
```

The trailing `\` swallows the newline between lines in multi-line TOML strings.

## Environment variables

| variable | does |
| --- | --- |
| `STARSHIP_CONFIG` | config file path |
| `STARSHIP_CACHE` | cache directory |
| `STARSHIP_LOG` | log level (`error`, `warn`, `info`, `debug`, `trace`) |
| `STARSHIP_SHELL` | override detected shell |

```fish
set -gx STARSHIP_CONFIG ~/.config/starship/jack.toml
set -gx STARSHIP_LOG debug
```

## Troubleshooting

**Prompt did not change**
Run `starship prompt` directly. If that works, shell init is the problem — re-run
`starship init fish | source`.

**Icons are boxes**
The terminal font isn't a Nerd Font, or the glyph is missing. Install a full Nerd
Font and select it in the terminal.

**A module never appears**
Check `starship explain` and `starship print-config`. Language modules only show when
their marker files/toolchains exist.

**Slow prompt**
`starship timings` finds the culprit. Lower `command_timeout`, raise `scan_timeout`,
or disable heavy modules (`package`, `git_status` in huge repos).

**Colors look wrong over SSH / tmux**
Ensure the terminal and tmux advertise true color (`COLORTERM=truecolor`,
`terminal-features` for RGB in tmux).

**Debug output**

```bash
STARSHIP_LOG=trace starship prompt
```

**Reset a module to defaults**
Delete its `[module]` table, or check `starship print-config` for the default value.
