{ config, pkgs, ... }:
{
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Sysadmin-related packages
  environment.systemPackages = with pkgs; [
    # Source control    
    git

    # Automation
    nixops
    ansible

    # Debugging
    wireshark-qt

  ];
}
