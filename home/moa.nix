# Home-manager module for user `moa`.
#
# Everything under ./files mirrors the real ~/.config tree that was migrated
# from the Fedora machine, and is linked into place via `xdg.configFile`.
# The `niri-dms` and `dms-seed` directories are handled separately (see the
# activation script) because DMS rewrites those files at runtime.
{ config, pkgs, lib, ... }:
let
  # Recursively collect every regular file under `dir` and return an attrset of
  # "relative/path" -> absolute source path, ready for `xdg.configFile`.
  collectFiles =
    dir:
    let
      go =
        base: prefix:
        lib.concatMapAttrs
          (
            name: type:
            let
              path = base + "/${name}";
              rel = if prefix == "" then name else "${prefix}/${name}";
            in
            if type == "directory" then go path rel else { ${rel} = path; }
          )
          (builtins.readDir base);
    in
    go dir "";
in
{
  home.username = "moa";
  home.homeDirectory = "/home/moa";
  home.stateVersion = "25.11";

  xdg.enable = true;

  # Link the migrated ~/.config tree.
  xdg.configFile = lib.mapAttrs (_: source: { inherit source; }) (collectFiles ./files);

  # DMS generates ~/.config/niri/dms/*.kdl and rewrites ~/.config/dms/*.json at
  # runtime, so we must not symlink them from the store (that would be
  # read-only). Instead seed them on first activation: existing files are left
  # untouched, so the real (already-configured) files win on this machine and
  # fresh machines get a working starting point that DMS can then rewrite.
  home.activation.seedRuntimeConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _seed_dir() {
      _target="$HOME/.config/$1"
      _src="$2"
      $DRY_RUN_CMD mkdir -p "$_target"
      for _f in "$_src"/*; do
        [ -e "$_f" ] || continue
        _base="$(basename "$_f")"
        if [ ! -e "$_target/$_base" ]; then
          $DRY_RUN_CMD cp -r "$_f" "$_target/$_base"
        fi
      done
    }
    _seed_dir "niri/dms" ${./niri-dms}
    _seed_dir "dms" ${./dms-seed}
  '';

  # Legacy compatibility symlink that some apps / older DMS docs expect.
  home.file.".config/DankMaterialShell".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dms";

  # DMS is not in nixpkgs; its flake ships the package and this home module.
  # Settings/clipboard/plugin files are intentionally left unmanaged (seeded
  # above) so the DMS settings GUI can keep writing them.
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
  };
  programs.zoxide = {
  enable = true;
  enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    # shell & terminal
    fish
    starship
    zellij
    tmux
    yazi
    wezterm
    kitty
    alacritty
    foot
    ghostty
    # editors
    neovim
    helix
    vim
    lite-xl
    # cli
    btop
    htop
    fastfetch
    cava
    lazygit
    glow
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide
    jq
    # launchers / bars / notifications
    rofi
    fuzzel
    wlogout
    swaylock
    swaynotificationcenter
    mako
    eww
    ironbar
    waybar
    quickshell
    # media
    mpv
    mpd
    ncmpcpp
    playerctl
    # theming / settings
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    nwg-look
    nwg-displays
    xsettingsd
    wallust
    matugen
    # desktop utils
    xarchiver
    qalculate-gtk
    pavucontrol
    wireshark
    conky
    spicetify-cli
    catnip
    fum
    aichat
    # wayland helpers
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    brightnessctl
    # portals
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr
    # arcade
    rustup
    tdf
    remmina
    sshm
    tailscale
    openvpn
    librewolf
    age
    goose-cli
     cline
     pi-coding-agent
    codex
    spicetify-cli
     spotify
     freerdp
     gh 
     gcc
     gnumake
     dotnet-sdk
     dotnet-sdk_10
     #
  ];

  programs.home-manager.enable = true;
}
