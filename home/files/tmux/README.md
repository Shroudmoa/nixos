# tmux config

Minimal tmux setup — prefix `C-a`, vi-style panes, tokyonight moon colors.

Based on [tonybanters](https://github.com/tonybanters)' tmux repo on GitHub. Thanks Tony.

## Files

| file | what |
| --- | --- |
| `tmux.conf` | the actual config |
| `tmux.conf.local` | local overrides / plugins (mostly commented out) |

## Install

```sh
git clone <this-repo> ~/.config/tmux
```

Add to `~/.tmux.conf`:

```tmux
source-file ~/.config/tmux/tmux.conf
```

Reload: `prefix + r`

## Cheatsheet

**Prefix is `C-a`** (not `C-b`). Send a literal `C-a` with `C-a C-a`.

### Panes
| keys | do |
| --- | --- |
| `prefix \|` | split vertical |
| `prefix -` | split horizontal |
| `prefix h/j/k/l` | move left/down/up/right |
| `alt h/j/k/l` | move panes, no prefix |
| `prefix x` | kill pane |

New panes open in the current directory.

### Windows
| keys | do |
| --- | --- |
| `prefix c` | new window |
| `prefix n` / `p` | next / previous |
| `prefix 1..9` | jump to window |
| `alt 1..9` | jump to window, no prefix |
| `shift ←/→` | previous / next window |
| `prefix ,` | rename window |
| `prefix &` | kill window |

Windows are 1-indexed and renumber automatically.

### Copy mode (vi)
| keys | do |
| --- | --- |
| `prefix [` | enter copy mode |
| `v` | start selection |
| `C-v` | rectangle select |
| `y` | yank + exit |
| `/` `?` | search forward / back |

### Misc
| keys | do |
| --- | --- |
| `prefix r` | reload config |
| `prefix d` | detach |
| `prefix ?` | list all keybindings |
| `prefix :` | command prompt |

## Notes

- `mouse on` — click, drag, resize
- system clipboard enabled
- true color (`RGB`) enabled
- `tmux-256color` as default terminal
- status bar: current window shows path, right side shows session + prefix indicator
