# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ 
      # Include the appropriate file for current hardware config
      # Symlink the appropriate config to hardware-configuration-current.nix from hardware/ for this to work!
      ./hardware-configuration-current.nix
      # Include the appropriate file for the current role
      # Symlink the appropriate config to role-current.nix from roles/ for this to work!
      ./role-current.nix
    ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
