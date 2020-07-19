# An overlay so that the unstable version of the mullvad client can be used on stable nixOS.
let unstable = import <nixos-unstable> { };
in { config, pkgs, ... }: {
  #nixpkgs.overlays = [ mullvad-overlay ];
  imports = [ ../../../services/mullvad.nix ];
  systemd.services.mullvad-daemon.enable = true;
  environment.systemPackages = [ unstable.pkgs.mullvad-vpn ];
}
