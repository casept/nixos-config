{ config, pkgs, ... }: {
  # I like systemd, fite me
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.systemd-boot.editor = false;

  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  networking.interfaces.wwp0s20u4i6.useDHCP = true;

  networking.hostName = "casept-x230t";
  networking.hostId = "8a629679";

  fileSystems."/" = {
    device = "rpool/root/nixos";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/541E-6256";
    fsType = "vfat";
  };

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Add ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  # ZFS services
  services.zfs.autoSnapshot.enable = true;
  # TODO: Can we do this when not on bat/working?
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  # Allegedly, ZFS does not like the kernel scheduler messing with it
  # TODO: Research how to set this only for /dev/sda
  boot.kernelParams = [ "elevator=none" ];
}
