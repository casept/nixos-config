{ lib, pkgs, ... }:

{

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  services.fstrim.enable = true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nix.settings.max-jobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Firmware updates
  services.fwupd.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
