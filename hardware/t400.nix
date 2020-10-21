{ lib, ... }:

{
  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sdhci_pci" "e1000" "usb-storage" ];

  # Ethernet driver is needed to allow unlocking root from initramfs over SSH
  boot.initrd.kernelModules = [ "dm-snapshot" "e1000" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = lib.mkDefault "conservative";

  # Enable TLP
  services.tlp.enable = true;
}
