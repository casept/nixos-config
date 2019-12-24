{ config, pkgs, ... }:
{
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Touch and pen-related packages
  environment.systemPackages = with pkgs; [
    krita
    xournalpp
  ];
}
