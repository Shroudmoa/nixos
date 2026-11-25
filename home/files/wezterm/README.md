# NEXUS v2 — next-gen WezTerm config

A complete rebuild of this repo's terminal setup: **three original palettes**,
a **sunrise-aware theme engine**, **local plugins**, a **command-palette command
set**, **process-aware tabs**, and a **live status line** — all in small Lua
modules instead of one 200-line file.

The original setup is kept untouched as [`wezterm.classic.lua`](wezterm.classic.lua)
and [`colors/dank-theme.toml`](colors/dank-theme.toml). To go back, copy
`wezterm.classic.lua` over `wezterm.lua`. Its old screenshot is in
[`preview/acats.png`](preview/acats.png).

---

## Why WezTerm (the actual reason)

WezTerm is not just a prettier terminal emulator. It is the only mainstream
terminal where the **terminal emulator, window manager and session manager are
one programmable system**:

1. **Lua is the whole config language.** Not a JSON file plus a shell script plus
   a keybinding daemon. Logic like "switch palette at sunset", "show git branch
   in the status line" or "only dim inactive panes in dark mode" lives in the
   same place as `font_size`.
2. **Multiplexing is built in.** Workspaces, tabs, panes and remote domains are
   native — no tmux process to babysit, no nested key tables fighting each other.
   `wezterm cli` still gives you the scriptable session control of tmux.
3. **One config, every OS.** The same file renders correctly on macOS, Wayland,
   X11, Windows and WSL. This config swaps blur implementation per platform in
   four lines instead of four dotfiles.
4. **GPU-accelerated text rendering.** Ligatures, font fallback, per-`italic`/
   `bold` font rules, Oklab-blended background gradients and transparent glass
   are cheap enough to leave on all day.
5. **Modern terminal protocols.** Kitty keyboard protocol, OSC 7 working
   directory tracking, shell integration, hyperlinks, iTerm image protocol and
   ConEmu progress reporting are first-class — TUIs and SSH sessions behave the
   way their authors intended.
6. **Runtime reconfiguration.** `window:set_config_overrides()` means themes,
   opacity and focus mode can change per window, *live*, without restarting or
   losing your shell history.
7. **A plugin contract, not a plugin manager convention.** Any Git repo with a
   `plugin/init.lua` exposing `apply_to_config` is a plugin. The modules in
   `lua/nexus/` follow that same shape, so promoting one to a standalone plugin
   is a copy/paste away — with **zero network dependencies** on first launch.

That is the reason: **less tooling around the terminal, more terminal.**

---

## What is new in v2

- **Aura Glass** — polar-night navy, cyan + lilac. Default at night.
- **Daylight Porcelain** — clean light surface, cobalt + amber. Default by day.
- **Nocturne Void** — near-black, electric lime + magenta. High contrast.
- **Theme engine** that follows OS light/dark mode, or real sunrise/sunset if you
  set `latitude`/`longitude` in `wezterm.lua`. `LDR t` picks manually;
  `LDR Ctrl+t` returns to auto.
- **Zen mode** (`LDR f`) — hides the tab bar, widens padding, increases opacity.
- **Surface cycling** (`LDR o`) — Glass → Frost → Solid, live.
- **NEXUS command set** in the command palette (fuzzy search for "NEXUS").
- **Launcher recipes** for shell, editor, btop, git log, version check.
- **Snippet launcher** (`LDR u`) to send common commands into the active pane.
- **Workspace picker / new / rename** with named presets.
- **Status line** with workspace, key-table state, git branch (cached), battery,
  clock, cwd and foreground process.
- **Tab bar** with powerline separators, tab index, process icons, unseen-output
  dot, zoom marker and ConEmu progress percentage.
- **System check** (`LDR D`) — toast with WezTerm version, theme, shell, config dir.
- Everything reloads automatically when a module or palette TOML changes.

---

## Install

```bash
# from this repo
ln -sf "$PWD/wezterm.lua" ~/.config/wezterm/wezterm.lua
ln -sfn "$PWD/lua" ~/.config/wezterm/lua
ln -sfn "$PWD/colors" ~/.config/wezterm/colors
```

A Nerd Font is recommended (`JetBrainsMono Nerd Font Mono` by default). WezTerm
also bundles its own symbol fallback font, so glyphs still render without one.

Requires a reasonably recent WezTerm (2024+). Nightly adds progress percentages
in tabs; everything else works on stable.

---

## Themes

| Palette | File | Mode | Feel |
| --- | --- | --- | --- |
| Aura Glass | `colors/aura.toml` | dark | deep navy, cyan/lilac, frosted glass |
| Daylight Porcelain | `colors/daylight.toml` | light | paper white, cobalt/amber |
| Nocturne Void | `colors/nocturne.toml` | dark | near black, lime/magenta, high contrast |

The TOML files own the 16-color terminal palette. UI colors (tab bar, window
frame, gradient, accents) are derived per theme in `lua/nexus/themes.lua`, so a
theme switch updates the *whole* window, not just ANSI colors.

To pin a theme at boot, edit `wezterm.lua`:

```lua
default_theme = 'nocturne', -- 'auto' | 'aura' | 'daylight' | 'nocturne'
```

To use the real sun instead of OS appearance:

```lua
latitude = 37.7749,
longitude = -122.4194,
```

---

## Keybindings

Leader is **ALT + e** (`LDR`).

### Core

| Key | Action |
| --- | --- |
| `LDR Ctrl+a` | send `Ctrl+a` (tmux escape hatch) |
| `LDR [` | copy mode |
| `LDR /` | search scrollback |
| `LDR K` | clear scrollback |
| `LDR :` | command palette |
| `LDR g` | **goto mode** (see below) |
| `LDR L` | reload configuration |
| `LDR D` | system check toast |
| `LDR d` | debug overlay |

### Tabs

| Key | Action |
| --- | --- |
| `LDR c` | new tab |
| `LDR w` | tab navigator |
| `LDR a` | last tab |
| `LDR p` / `LDR n` | previous / next tab |
| `LDR 1`–`LDR 9` | go to tab by index |
| `LDR ,` | rename tab |
| `LDR .` / `LDR m` | move-tab mode (`h`/`j` left, `k`/`l` right) |

### Panes

| Key | Action |
| --- | --- |
| `LDR q` / `LDR "` | split vertically (stacked) |
| `LDR W` / `LDR %` | split horizontally (side by side) |
| `LDR h j k l` / arrows | focus pane |
| `LDR Space` | rotate panes |
| `LDR z` | zoom pane |
| `LDR x` / `LDR X` | close pane / close tab |
| `LDR !` | move pane to new tab |
| `LDR r` | resize mode (`h j k l`, arrows, `< > - +`, Esc/Enter exits) |
| middle click | paste primary selection |

### Workspaces & NEXUS systems

| Key | Action |
| --- | --- |
| `LDR s` | fuzzy workspace launcher (all workspaces) |
| `LDR S` | named workspace picker |
| `LDR N` / `LDR R` | new / rename workspace |
| `LDR t` | theme picker |
| `LDR T` | next theme (pins it) |
| `LDR Ctrl+t` | back to automatic theme |
| `LDR o` | cycle surface opacity |
| `LDR f` | toggle zen mode |
| `LDR u` | command snippets |
| `LDR F` | fullscreen |
| `LDR B` | launcher menu (recipes) |
| `LDR = / - / 0` | increase / decrease / reset font size |

### Goto mode (`LDR g`)

| Key | Action |
| --- | --- |
| `g w` / `g n` | workspace picker / new workspace |
| `g t` | tab navigator |
| `g p` | pane select |
| `g c` | command palette |
| `g l` | launcher menu |
| `g s` | snippets |
| `g a` | last tab |
| `Esc` / `Enter` | exit mode |

---

## Layout

```
wezterm.lua              boot sequence + user options
wezterm.classic.lua      previous configuration (archived)
colors/*.toml            terminal palettes (loaded at runtime)
lua/nexus/
  init.lua               orchestrator: core config, typography, glass effects
  themes.lua             palette loader, day/night engine, override manager
  commands.lua           command palette, launcher, all namespaced commands
  keys.lua               leader, keybindings, key tables, mouse
  ui.lua                 tab formatter, window title, status line
  core.lua               glyphs, path/process helpers, format helpers
```

Each module exposes `apply(config, options)` (or a small command API), matching
the WezTerm plugin contract. To add a local plugin:

1. Drop a module in `lua/nexus/` (or `lua/plugins/` and add it to `package.path`).
2. Give it an `apply(config, options)` function.
3. Call it from `lua/nexus/init.lua`.

External WezTerm plugins can still be used normally:

```lua
local plugin = wezterm.plugin.require 'https://github.com/owner/repo'
plugin.apply_to_config(config)
```

They are deliberately opt-in here so the config never blocks on a network clone.

---

## Notes

- `COLORTERM=truecolor` is exported for modern TUI color detection.
- Kitty keyboard protocol is enabled; applications that support it get accurate
  modifier and event reporting.
- With coordinates set, the theme engine checks sunrise/sunset every 5 minutes
  using `wezterm.time` and `Time:sun_times()`.
- Manual theme choices are session-pinned; `LDR Ctrl+t` restores automatic mode.
