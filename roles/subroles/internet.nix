{ config, pkgs, ... }:
{ 
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Sysadmin-related packages
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # Mail
    thunderbird

    # P2P
    deluge
    syncthing-gtk

    # Messengers
    tdesktop
    discord
    signal-desktop

    # Misc
    mullvad-vpn

  ];
}
