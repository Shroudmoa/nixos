# Shared home-manager module for the headless `server` host.
#
# It reuses the terminal-friendly dotfiles from ./files (fish functions, tmux,
# starship, helix, nvim, yazi, ...) but deliberately does NOT link any of the
# desktop/Wayland configs. The desktop host keeps using ./files in full via
# home/moa.nix.
{ pkgs, lib, ... }:
let
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

  # Only these trees are relevant on a headless server. Everything else under
  # ./files (hypr, waybar, rofi, gtk, telegram, ...) stays on the desktop host.
  keepTrees = [
    "fish/functions"
    "fish/conf.d"
    "tmux"
    "starship"
    "helix"
    "nvim"
    "yazi"
    "lazygit"
    "htop"
    "glow"
    "fastfetch"
    "vim"
    "zellij"
  ];

  inTree = name: lib.any (tree: name == tree || lib.strings.hasPrefix "${tree}/" name) keepTrees;

  # Docs, lockfiles and images add noise to the store and are not needed at
  # runtime.
  skipFile = name: lib.any (suffix: lib.strings.hasSuffix suffix name) [
    ".md"
    "LICENSE"
    "lazy-lock.json"
    ".png"
    ".gitignore"
  ];

  shared = lib.filterAttrs (name: _: inTree name && ! (skipFile name)) (collectFiles ./files);
in
{
  home.stateVersion = "25.11";
  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };

  xdg.configFile =
    (lib.mapAttrs (_: source: { inherit source; }) shared)
    // {
      # Server-specific fish config: no DISPLAY, no GUI aliases.
      "fish/config.fish".source = ./server-files/fish/config.fish;
    };

  home.packages = with pkgs; [
    # shell / terminal
    fish
    starship
    tmux
    zoxide
    fzf
    # editors / file management
    nvim
    helix
    vim
    yazi
    # CLI tools used by the dotfiles above
    eza
    bat
    ripgrep
    fd
    jq
    glow
    htop
    btop
    fastfetch
    lazygit
    age
    zstd
    zip
    unzip
  ];

  # GUI stuff deliberately absent: telegram-desktop, firefox, kitty, wezterm,
  # swaync, waybar, hyprland, dank-material-shell, onlyoffice, teamviewer, ...
  # If you ever need a TUI-only addition, put it in one of the per-user modules.

  programs.home-manager.enable = true;
}
