{ config, pkgs, ... }:

  # Enable support for installing from unstable without having to add it using nix-channel first
  let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  in
  {
    nixpkgs.config = {
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
    };
  

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Sysadmin-related packages
  environment.systemPackages = with pkgs; [
    # Browsers
    unstable.google-chrome
    unstable.firefox

    # Mail
    unstable.thunderbird

    # P2P
    deluge
    unstable.syncthing-gtk

    # Messengers
    unstable.tdesktop
    unstable.discord
    unstable.signal-desktop

    # Misc
    unstable.mullvad-vpn

  ];
}
