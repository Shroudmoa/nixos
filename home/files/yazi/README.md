# Yazi Config

Minimal Yazi config with Rose-Pine and a few plugins.

![Yazi Preview](preview/acats.png)

## Install Plugins

```bash
# Official plugins
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:piper
ya pkg add yazi-rs/plugins:smart-enter
ya pkg add yazi-rs/plugins:toggle-pane
ya pkg add yazi-rs/plugins:chmod

# Community plugins
ya pkg add ndtoan96/ouch
ya pkg add kastrbl4nik/kra
ya pkg add macydnah/office
ya pkg add boydaihungst/mediainfo
ya pkg add DreamMaoMao/fg

# Flavor
ya pkg add Mintass/rose-pine
```

`zoxide` and `magick` are built into Yazi, so no separate install is needed.

`video-timeline` is not available via `ya pkg`, so install it manually:

```bash
git clone https://github.com/nbaud/yazi-video-timeline.git /tmp/yazi-video-timeline
cp -r /tmp/yazi-video-timeline/video-timeline.yazi ~/.config/yazi/plugins/
chmod +x ~/.config/yazi/plugins/video-timeline.yazi/preview.sh
```

## Keybindings

| Key | Action |
|---|---|
| `T` | Maximize / restore preview |
| `M` | Show / hide preview |
| `l` | Enter directory or open file |
| `F` | Search file contents (`rg` via `fg`) |
| `z` | Jump with `zoxide` |
| `e` | Extract archive |
| `C` | Compress with `ouch` |
| `Ctrl+d` | Drag and drop |
| `A` | Create new directory |
| `w`, then `x` | Open task manager / cancel task |

> Note: `M` is also bound to `chmod` in `keymap.toml`.
