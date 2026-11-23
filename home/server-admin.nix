# Home-manager module for `admin` on the server host.
# The shared shell/terminal setup lives in server-common.nix.
{ pkgs, ... }:
{
  imports = [ (import ./server-common.nix) ];

  home.packages = with pkgs; [
    gh
    sqlite
    postgresql
    redis
  ];
}
