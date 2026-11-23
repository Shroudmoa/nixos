# nixos

Personal NixOS flake (flake-parts + import-tree + home-manager).

This branch (`niri`) is set up so that **all of the real dotfiles from the Fedora
machine are managed declaratively** and can be used both on NixOS and (standalone)
on Fedora.

## Layout

```
flake.nix                     # inputs + flake-parts entry point
modules/                      # everything here is auto-imported by import-tree
  parts.nix                   # flake-parts: supported systems
  features/
    home-manager.nix          # exposes flake.homeModules.moa + flake.homeConfigurations
    niri.nix                  # enables the niri compositor + session (package = pkgs.niri)
  hosts/
    my-machine/
      default.nix             # nixosConfigurations.myMachine
      configuration.nix       # system config + wires home-manager.users.moa
      hardware.nix            # generated hardware config
    server/
      default.nix             # nixosConfigurations.server (headless)
      configuration.nix       # SSH + 3 users, GUI config kept commented out
      hardware.nix            # copied from my-machine; regenerate for real hardware
  features/
    server-home.nix           # exposes homeModules.server{Common,Admin,Vm,Moa}
home/                         # NOT auto-imported (kept outside modules/)
  moa.nix                     # the desktop home-manager module (links all of ./files)
  files/                      # migrated ~/.config tree (mirrors the real paths)
    niri/config.kdl
    wezterm/wezterm.lua
    fish/config.fish
    ... (everything under ~/.config that is real config)
  niri-dms/                   # seed for ~/.config/niri/dms/*.kdl (DMS rewrites these)
  dms-seed/                   # seed for ~/.config/dms/* (DMS rewrites these at runtime)
  server-common.nix           # shared headless home module (reuses TUI parts of ./files)
  server-{admin,vm,moa}.nix   # per-user extras on the server
  server-files/fish/config.fish # server-safe fish config (no DISPLAY/GUI aliases)
```

### How the configs are wired

`home/moa.nix` walks `home/files/` recursively and maps every file to an
`xdg.configFile` entry, so `home/files/wezterm/wezterm.lua` lands at
`~/.config/wezterm/wezterm.lua`. To add/change a config, just drop the file in
`home/files/` at the matching path.

The `niri/dms/*.kdl` files and the `dms/*` files are **not** symlinked from the
store, because DankMaterialShell regenerates them at runtime. Instead an
activation script seeds them once (only if missing) into `~/.config/niri/dms/`
and `~/.config/dms/`. The includes in `niri/config.kdl` use
`include optional=true "dms/..."` so niri still starts if DMS has not run yet.

### DankMaterialShell (DMS)

DMS is not in nixpkgs, so the `dank-material-shell` flake input provides the
`dms-shell` package and a home-manager module (imported in
`modules/features/home-manager.nix`). `home/moa.nix` enables it:

```nix
programs.dank-material-shell = {
  enable = true;
  systemd.enable = true;   # dms.service, bound to graphical-session.target
};
```

The DMS *settings* (`~/.config/dms/settings.json`, `clsettings.json`,
`plugin_settings.json`) are deliberately **not** managed declaratively, so the
DMS settings GUI can keep writing them; they are seeded once from `home/dms-seed/`
(see above). DMS is started by its systemd user service, so `niri/config.kdl`
does not spawn it.

## Usage

### NixOS (the `myMachine` host)

```sh
sudo nixos-rebuild switch --flake ~/.config/nixos#myMachine
```

### NixOS (the headless `server` host)

```sh
sudo nixos-rebuild switch --flake ~/.config/nixos#server
```

Three users are created: `admin` (wheel/sudo), `vm`, and `moa`. All get fish,
tmux, starship, fzf/zoxide, nvim/helix, yazi and the other TUI dotfiles from
`home/files`. No X11, no compositor, no GNOME, no pipewire, no GUI apps —
Telegram, Firefox, TeamViewer, OnlyOffice etc. only exist on `myMachine`. The
desktop-related NixOS options are still present as comments in
`modules/hosts/server/configuration.nix`.

> **Before first boot:** replace the three placeholder SSH public keys at the
> top of `modules/hosts/server/configuration.nix`. Password auth and root login
> are disabled, so with the placeholders nobody can log in via SSH. Once logged
> in as `admin`, run `passwd admin` to set a password for `sudo`.

Hardware is copied from `my-machine`; run
`nixos-generate-config --show-hardware-config` on the target and replace
`modules/hosts/server/hardware.nix` if it is different hardware.

### Fedora (standalone home-manager)

The same dotfiles can be applied on Fedora without NixOS:

```sh
nix run github:nix-community/home-manager -- switch --flake ~/.config/nixos#moa@fedora
```

> First run will complain about existing files; pass `-b hm-backup` to back them
> up instead of failing:
> `nix run github:nix-community/home-manager -- switch -b hm-backup --flake ~/.config/nixos#moa@fedora`

## Notes / gotchas

- **Secrets were stripped** while migrating (they must not live in the world-readable
  Nix store or in git): `aichat/config.yaml` (API key), `kdeconnect` private key +
  trusted devices, `sunshine` state/credentials/portal token, the OpenWeatherMap key
  in `conky/grumimosa/scripts/weather.sh`. Re-add those out-of-band (e.g. via
  `sops-nix`, `agenix`, or `home.file` with a secret path).
- **Skipped** (state/cache/app data, not config): browser profiles (`net.imput.helium`,
  `mozilla`, `zen`, `thunderbird`), `opencode`, `Cursor`, `obs-studio`, `remmina`,
  `teamviewer`, `tele`, `libreoffice`, `browsh`, `terminal-browser-*`, `dconf`,
  `pulse`, `gh`, plus all `*-backup-*` directories.
- **`~/.config/systemd/user` was dropped** from the migration: it contained derived
  `.wants/` enablement symlinks (dereferenced into full unit copies) and units with
  hardcoded Fedora paths (`/usr/bin/sunshine`, `/usr/libexec/...`, another user's
  `/home/bluebyt`), and the `niri.service.wants/dms.service` copy conflicts with the
  home-manager-managed `dms.service`. Systemd user units are managed by NixOS/
  home-manager instead.
- **DankMaterialShell (`dms`)** is installed from the `dank-material-shell` flake
  input (built from source), and started via its systemd user service
  (`dms.service`, bound to `graphical-session.target`). The migrated `dms/*`
  files are seeded once into `~/.config/dms/` so the settings GUI keeps working.
- Some migrated files are normally rewritten by their app at runtime (e.g.
  `mimeapps.list`, `gtk-3.0/bookmarks`, `qt5ct`/`qt6ct` configs). They are linked
  read-only; if an app complains, delete that entry from `home/files/`.
