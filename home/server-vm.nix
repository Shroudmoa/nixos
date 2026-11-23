# Home-manager module for `vm` on the server host.
{ pkgs, ... }:
{
  imports = [ (import ./server-common.nix) ];

  home.packages = with pkgs; [
    socat
    nmap
  ];
}
