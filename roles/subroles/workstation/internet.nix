{ config, pkgs, ... }:
{ 
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Sysadmin-related packages
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # Misc
    mullvad-vpn

  ];
}
