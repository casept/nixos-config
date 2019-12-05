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

  # Touch and pen-related packages
  environment.systemPackages = with pkgs; [
    # Games
    unstable.steam
    unstable.steam-run
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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "eu";
}
