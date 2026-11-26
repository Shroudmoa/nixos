{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
      inputs.home-manager.nixosModules.home-manager
    ];
  nix.settings.experimental-features = [
  "nix-command"
  "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixosbtw"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.plugins = with pkgs; [
  networkmanager-openvpn
  ];
  services.openvpn.servers.visionmaxx = {
    autoStart = false;
    config = ''
      config /etc/openvpn/client/visionmaxx.conf
    '';
  };


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.teamviewer.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.moa = {
    isNormalUser = true;
    description = "moa";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Use fish as an available login shell.
  programs.fish.enable = true;

  # Home-manager manages all of moa's ~/.config dotfiles (migrated from Fedora).
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.moa = self.homeModules.moa;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Work around patchelf 0.19.2 producing overlapping LOAD segments in
  # autoPatchelf'd non-PIE binaries, which makes teamviewerd crash in ld.so
  # before it even starts (NixOS/nixpkgs#576412). A 2 MiB page keeps .dynamic
  # in its own writable segment. Remove once patchelf >= 0.19.3 lands.
  nixpkgs.overlays = [
    (final: prev: {
      teamviewer = prev.teamviewer.overrideAttrs (old: {
        patchelfFlags = (old.patchelfFlags or [ ]) ++ [ "--page-size" "2097152" ];
        # The GUI is X11-only; fall back to the xwayland-satellite display
        # (see home/moa.nix) when launched from a shell without DISPLAY set.
        makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
          "--set-default"
          "DISPLAY"
          ":99"
        ];
        # TeamViewer's embedded QtWebEngine (used for the company SSO window)
        # dlopens the hard-coded name "libudev.so.0". Modern systemd only ships
        # libudev.so.1, so that dlopen fails and Chromium's udev loader triggers
        # an IMMEDIATE_CRASH() (SIGTRAP) as soon as the embedded browser starts.
        # RTlib is already in libQt5WebEngineCore.so.5's RUNPATH, so a compat
        # symlink there is found by dlopen without changing LD_LIBRARY_PATH.
        postFixup = (old.postFixup or "") + ''
          ln -sf ${final.systemd}/lib/libudev.so.1 \
            "$out/share/teamviewer/tv_bin/RTlib/libudev.so.0"
        '';
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    curl
    lazygit
    helix
    fish
    kitty
    telegram-desktop
    fuzzel
    btop
    alacritty
    (appimage-run.override {
      extraPkgs = pkgs: [ 
        pkgs.libgpg-error 
      ];
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # services.tailscale.enable = true;
  services.tailscale = {
  enable = true;
  extraSetFlags = [ "--accept-dns=false" ];
  };

  networking.nameservers = [
    "192.168.1.10"
    "192.168.1.11"
    "9.9.9.9"
    "192.168.0.1"

  ];


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 3389 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
   networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

};


}
