# Niri is configured through home-manager (see ../../home/files/niri/config.kdl
# and the `niri-dms` seed in ../../home/moa.nix), so we only need the compositor
# and its session here. This keeps the live config at ~/.config/niri/config.kdl
# where DMS can regenerate its `dms/*.kdl` includes at runtime.
{ self, inputs, ... }:
{
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
}
