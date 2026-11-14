{ self, inputs, ... }:
let
  # Shared home-manager module: our dotfiles plus the DMS home module (which
  # installs the dms-shell package and its systemd user service).
  moaModule = {
    imports = [
      (import ../../home/moa.nix)
      inputs.dank-material-shell.homeModules.dank-material-shell
    ];
  };
in
{
  # The home-manager module lives outside ./modules so that import-tree does
  # not try to evaluate it as a flake-parts module.
  flake.homeModules.moa = moaModule;

  # Standalone home-manager config, so the same dotfiles can be applied on
  # this Fedora machine with:
  #   nix run github:nix-community/home-manager -- switch --flake ~/.config/nixos#moa@fedora
  flake.homeConfigurations."moa@fedora" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    modules = [ moaModule ];
  };
}
