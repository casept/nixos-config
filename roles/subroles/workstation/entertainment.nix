{ config, pkgs, ... }:
{
  # Entertainment-related packages
  environment.systemPackages = with pkgs; [
    # Games
    multimc
    (wine.override { wineBuild = "wineWow"; })
   
  ];
  
  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
