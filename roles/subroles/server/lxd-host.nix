let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in
{
  system.stateVersion = "23.05";
  virtualisation.lxc.lxcfs.enable = true;
  virtualisation.lxd = {
    enable = true;
    recommendedSysctlSettings = true;
  };

  # Create a bridge
}
