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

  # Development packages
  environment.systemPackages = with pkgs; [
    # Reversing
    unstable.ghidra-bin
    unstable.python37Packages.binwalk-full
    unstable.jd-gui

    # Networking
    unstable.nmap

  ];

  services.lorri.enable = true;
  
  programs.adb.enable = true;
 
}
