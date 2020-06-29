# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [
    # Include the appropriate file for current hardware config
    # Symlink the appropriate config to hardware-configuration-current.nix from hardware/ for this to work!
    ./hardware-configuration-current.nix
    # Include the appropriate file for the current role
    # Symlink the appropriate config to role-current.nix from roles/ for this to work!
    ./role-current.nix
    # Include the appropriate file for current box (not hardware, this file contains stuff like FS layout config.
    # Basically anything that is specific to a single physical machine).
    # Symlink the appropriate config to box-current.nix from boxes/ for this to work!
    ./box-current.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

  nixpkgs.overlays = [
    (self: super: {
      # Do not run some shitty, flaky tests
      python3 = super.python3.override {
        packageOverrides = python-self: python-super: {
          pycurl = python-super.pycurl.overrideAttrs
            (oldAttrs: { doInstallCheck = false; });
        };
      };
    })
  ];
}
