{ lib, ... }:

{

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sdhci_pci" "battery" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # To reduce risk of OOM
  nix.settings.max-jobs = lib.mkDefault 1;
  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";

  # Firmware updates
  services.fwupd.enable = true;

  #### Input configuration ####
  # Enable touchpad support.
  services.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Power
  services.thermald.enable = true;
}
