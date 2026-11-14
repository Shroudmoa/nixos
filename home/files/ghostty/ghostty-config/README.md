# Ghostty Configuration

My personal [Ghostty](https://ghostty.org) terminal configuration with automatic light/dark theme switching and enhanced readability.

## Features

- 🌓 **Automatic theme switching** - Solarized Light for day, Rose Pine for night
- 📖 **Enhanced readability** - Minimum contrast ratio of 3.0 for better code visibility
- 🔤 **FiraCode Nerd Font** - Programming font with ligatures and icons
- 🎨 **Multiple theme options** - Pre-configured alternatives ready to use

## Current Configuration

```ini
# Ghostty Configuration File

# Font settings
font-family = "FiraCode Nerd Font Mono"
font-size = 14

# Theme - automatically switches based on system light/dark mode
# Solarized Light with custom palette for better diff readability
theme = light:Builtin Solarized Light,dark:rose-pine

# Option 2: Zenbones Light - Soft warm tones with better readability
# theme = light:zenbones_light,dark:rose-pine

# Option 3: Seoulbones Light - Warm paper-like background
# theme = light:seoulbones_light,dark:rose-pine

# Option 4: Gruvbox Light Hard - More contrast, still warm
# theme = light:GruvboxLightHard,dark:rose-pine

# Option 5: Catppuccin Latte - Soft pastels with warm undertones
# theme = light:catppuccin-latte,dark:rose-pine

# Option 6: Rose Pine Dawn (original - softest colors)
# theme = light:rose-pine-dawn,dark:rose-pine

# Increase minimum contrast to ensure text is always readable
minimum-contrast = 3.0

# Window settings
window-padding-x = 10
window-padding-y = 10

# Cursor
cursor-style = block
cursor-style-blink = true

# Shell
command = /bin/bash

# Other settings
copy-on-select = true
confirm-close-surface = true
```

## Installation

### Prerequisites - Font Installation

This configuration uses FiraCode Nerd Font. Install it first:

#### macOS
```bash
# Using Homebrew
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
```

#### Arch Linux
```bash
# From AUR
yay -S ttf-firacode-nerd
# or
paru -S ttf-firacode-nerd
```

### Installing Ghostty

#### macOS
1. Download the latest release from [Ghostty's website](https://ghostty.org)
2. Open the DMG file and drag Ghostty.app to Applications
3. Launch Ghostty from Applications or Spotlight

#### Arch Linux
```bash
# Install from AUR (using yay)
yay -S ghostty-git

# Or using paru
paru -S ghostty-git

# Or build manually
git clone https://aur.archlinux.org/ghostty-git.git
cd ghostty-git
makepkg -si
```

### Installing This Configuration

```bash
# Clone this repository
git clone https://github.com/marcusziade/ghostty-config.git ~/Dev/ghostty-config

# Create config directory
mkdir -p ~/.config/ghostty

# Symlink the config (recommended for easy updates)
ln -sf ~/Dev/ghostty-config/config ~/.config/ghostty/config

# Or copy it (if you prefer)
cp ~/Dev/ghostty-config/config ~/.config/ghostty/config

# Verify installation
ghostty +validate-config
```

### Updating

If you used symlinks:
```bash
cd ~/Dev/ghostty-config
git pull
# Config will update automatically
```

If you copied the file:
```bash
cd ~/Dev/ghostty-config
git pull
cp config ~/.config/ghostty/config
```

## Customization

### Changing Themes
The config includes several pre-configured theme combinations. To switch themes, simply comment out the current theme line and uncomment your preferred option.

### Other Customizations
- **Font size**: Change `font-size = 14` to your preferred size
- **Padding**: Adjust `window-padding-x` and `window-padding-y` 
- **Shell**: Default is bash. Change `command = /bin/bash` to your preferred shell
- **Cursor**: Modify `cursor-style` and `cursor-style-blink` as needed

## Troubleshooting

### Config not loading?
1. Check the config location:
   - macOS/Linux: `~/.config/ghostty/config`
   - macOS (alternative): `~/Library/Application Support/com.mitchellh.ghostty/config`

2. Validate the config:
   ```bash
   ghostty +validate-config
   ```

3. View loaded configuration:
   ```bash
   ghostty +show-config
   ```

### Font not working?
Verify font installation:
```bash
# List available fonts
ghostty +list-fonts | grep -i fira
```

### Theme issues?
The automatic light/dark switching requires your OS to report the theme correctly. On Linux, this depends on your desktop environment. You can manually set a single theme by removing the `light:` and `dark:` prefixes.

## License

This configuration is provided as-is for anyone to use and modify.