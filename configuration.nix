{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
#  services.xserver.xkb.layout = "de";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/nixos-dotfiles/walls/wall1.png
    '';
    extraConfig = ''
      	Section "Monitor"
      	  Identifier "Virtual-1"
      	  Option "PreferredMode" "1920x1080"
      	EndSection
    '';
  };

  services.picom.enable = true;
  nixpkgs.config.allowUnfree = true;

  users.users.moa = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;
  programs.thunar.enable = true;
  services.teamviewer.enable = true;
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    neovim 
    niri
    wget
    git
    alacritty
    helix
    fish
    tmux
    fastfetch
    btop
    tailscale
    remmina
    dms
    pkgs.xfce.thunar
    fuzzel
    strongswan
    yazi
    rofi
    telegram-desktop
    opencode
    spotify
  ];
  services.tailscale.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  services.xrdp = {
    enable = true;
    defaultWindowManager = "xfce4-session";
    openFirewall = true;
  };
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 3389 38809 ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}

