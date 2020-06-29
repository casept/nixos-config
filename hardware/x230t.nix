{ config, lib, pkgs, ... }:

{

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    <nixos-hardware/lenovo/thinkpad/x230>
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";
  
  # Enable TLP
  services.tlp.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  #### Input configuration ####
  # Enable wacom support.
  services.xserver.modules = [pkgs.xf86_input_wacom];
  services.xserver.wacom.enable = true;
  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Fingerprint scanner
  #services.fprintd.enable = true;
  #security.pam.services.login.fprintAuth = true;
  #security.pam.services.xscreensaver.fprintAuth = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Audio
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # Needed for bluetooth support
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
}
