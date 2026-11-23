# Home-manager modules for the headless `server` host.
# Kept next to home-manager.nix so the flake-parts layout stays the same:
# host configs reference these via self.homeModules.<name>.
{ ... }:
{
  flake.homeModules.serverCommon = {
    imports = [ (import ../../home/server-common.nix) ];
  };
  flake.homeModules.serverAdmin = {
    imports = [ (import ../../home/server-admin.nix) ];
  };
  flake.homeModules.serverVm = {
    imports = [ (import ../../home/server-vm.nix) ];
  };
  flake.homeModules.serverMoa = {
    imports = [ (import ../../home/server-moa.nix) ];
  };
}
