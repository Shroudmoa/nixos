# Home-manager module for `moa` on the server host (headless variant).
# The full desktop version is still home/moa.nix.
{ pkgs, ... }:
{
  imports = [ (import ./server-common.nix) ];

  home.packages = with pkgs; [
    gh
  ];
}
