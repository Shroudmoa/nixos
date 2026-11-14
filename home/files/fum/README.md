# fum

Personal configuration for [fum](https://github.com/qxb3/fum), a TUI-based MPRIS music client.

- Repository: <https://github.com/qxb3/fum>
- Configuration docs: <https://github.com/qxb3/fum/wiki/Configuring>
- Config file: `~/.config/fum/config.jsonc`

## Preview

[![fum preview](preview/acats.png)](preview/acats.png)

## Keybindings

| Key | Action |
| --- | --- |
| `h` | Previous track |
| `l` | Next track |
| `space` | Play / pause |
| `j` | Seek backward 5 seconds |
| `k` | Seek forward 5 seconds |
| `up` | Volume +5 |
| `down` | Volume -5 |
| `m` | Mute (`volume(0)`) |
| `s` | Toggle shuffle |
| `r` | Cycle loop mode (none → playlist → track) |
| `t` | Toggle time display: length / remaining |
| `q`, `esc` | Quit |

## Mouse

- Click the progress bar to seek.
- Drag the progress bar to scrub.
- Click or drag the volume bar to change volume.
- Click the track-length label to toggle between length and remaining time.
- Click the previous / play-pause / next buttons.

## Layout

- 30×18 bordered widget, centered in the terminal.
- Cover art centered above track information.
- Current position, duration, and volume are shown below the controls.
