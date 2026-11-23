# Headless server host: same flake-parts structure as my-machine, but no
# desktop environment, no GUI apps, and three SSH users (admin, vm, moa).
{ self, inputs, ... }:
let
  # --- REPLACE THESE WITH REAL PUBLIC KEYS ------------------------------------
  # Until you do, nobody can log in over SSH (PasswordAuthentication is off).
  sshKeys = {
    admin = [ "ssh-ed25519 REPLACE_WITH_ADMIN_PUBLIC_KEY admin@server" ];
    vm = [ "ssh-ed25519 REPLACE_WITH_VM_PUBLIC_KEY vm@server" ];
    moa = [ "ssh-ed25519 REPLACE_WITH_MOA_PUBLIC_KEY moa@server" ];
  };
in
{
  flake.nixosModules.serverConfiguration = { config, lib, pkgs, ... }: {
    imports = [
      self.nixosModules.serverHardware
      inputs.home-manager.nixosModules.home-manager
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "server";

    # No NetworkManager on a server: systemd-networkd handles DHCP by default.
    networking.useDHCP = lib.mkDefault true;
    # networking.networkmanager.enable = true;
    # networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

    networking.nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "de";

    # --- Desktop / GUI config: kept for reference, intentionally disabled ------
    # services.xserver.enable = true;
    # services.xserver.xkb = { layout = "de"; variant = ""; };
    # services.displayManager.gdm.enable = true;
    # services.desktopManager.gnome.enable = true;
    # programs.niri.enable = true;
    # services.printing.enable = true;
    # security.rtkit.enable = true;
    # services.pipewire = {
    #   enable = true;
    #   alsa.enable = true;
    #   alsa.support32Bit = true;
    #   pulse.enable = true;
    # };
    # services.teamviewer.enable = true;
    # programs.firefox.enable = true;
    # nixpkgs.config.allowUnfree = true; # only needed if you add unfree packages

    # --- Users -----------------------------------------------------------------
    users.defaultUserShell = pkgs.fish;
    programs.fish.enable = true;

    users.users.admin = {
      isNormalUser = true;
      description = "admin";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = sshKeys.admin;
    };

    users.users.vm = {
      isNormalUser = true;
      description = "vm";
      openssh.authorizedKeys.keys = sshKeys.vm;
    };

    users.users.moa = {
      isNormalUser = true;
      description = "moa";
      openssh.authorizedKeys.keys = sshKeys.moa;
      # Add "wheel" here if moa should have sudo as well.
    };

    security.sudo.wheelNeedsPassword = true;

    # Home-manager wires the per-user dotfiles (fish, tmux, starship, nvim, ...).
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      users.admin = self.homeModules.serverAdmin;
      users.vm = self.homeModules.serverVm;
      users.moa = self.homeModules.serverMoa;
    };

    # Minimal system profile; the nicer CLI tools live in the home profiles.
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      fish
      tmux
      htop
      neovim
    ];
    # GUI packages that exist on my-machine but NOT here:
    # telegram-desktop, firefox, kitty, alacritty, fuzzel, wireshark, conky,
    # appimage-run, onlyoffice-desktopeditors, teamviewer, ...

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # --- Remote access ----------------------------------------------------------
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        PermitRootLogin = "no";
        X11Forwarding = false;
        AllowUsers = [ "admin" "vm" "moa" ];
      };
    };

    # Optional VPN, kept commented like in the desktop config.
    # services.tailscale = {
    #   enable = true;
    #   extraSetFlags = [ "--accept-dns=false" ];
    # };
    # networking.firewall.allowedUDPPorts = [ 41641 ]; # if enabling tailscale

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };

    system.stateVersion = "25.11";
  };
}
