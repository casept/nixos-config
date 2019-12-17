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

  #### Filesysem configuration ####
  # Configure encrypted boot device.
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/8ff732bc-94fe-42ec-883c-b0e7e960e5fc";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d7928b16-1690-4912-a50d-6a4aef21053b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E86A-C3BB";
      fsType = "vfat";
    };
  
  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  
  # Enable TLP
  services.tlp.enable = true;
  
  networking.hostName = "casept-x230t"; # Define your hostname.
  
  #### Input configuration ####
  # Enable wacom support.
  services.xserver.modules = [pkgs.xf86_input_wacom];
  services.xserver.wacom.enable = true;
  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Fingerprint scanner
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

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
