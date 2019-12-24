{ config, pkgs, ... }:
{
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Development packages
  environment.systemPackages = with pkgs; [
    # Reversing
    ghidra-bin
    python37Packages.binwalk-full
    jd-gui

    # Networking
    nmap

  ];

  services.lorri.enable = true;
  
  programs.adb.enable = true;
 
}
