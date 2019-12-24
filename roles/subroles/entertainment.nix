{ config, pkgs, ... }:
{
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Touch and pen-related packages
  environment.systemPackages = with pkgs; [
    # Games
    steam
    steam-run
    lutris
    multimc
    (wine.override { wineBuild = "wineWow"; })
    
    # A/V
    vlc

    # Ebooks
    calibre

  ];
  
  # Needed for steam.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
