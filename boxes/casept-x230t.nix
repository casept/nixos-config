{ config, pkgs, lib, environment, ... }: {
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

  # See https://grahamc.com/blog/erase-your-darlings for rationale behind this setup

  # Wiped on every boot
  fileSystems."/" = {
    device = "rpool/root/wipedonboot";
    fsType = "zfs";
  };
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/root/wipedonboot@blank
  '';

  fileSystems."/nix" = {
    device = "rpool/root/nixos";
    fsType = "zfs";
  };

  # Only place outside /home and /nix that persists state 
  fileSystems."/persist" = {
    device = "rpool/root/systempersist";
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

  # Redirect NetworkManager state
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  # Redirect Mullvad credentials and config
  environment.etc."mullvad-vpn" = { source = "/persist/etc/mullvad-vpn/"; };

  # Redirect the actual NixOS config directory
  environment.etc."nixos" = { source = "/persist/etc/nixos/"; };

  # Redirect user credentials
  environment.etc."shadow" = { source = "/persist/etc/shadow"; };
  environment.etc."shadow-" = { source = "/persist/etc/shadow-"; };

  # For services where state location can't be changed in the config, we use symlinks
  systemd.tmpfiles.rules = [
    # Redirect Bluetooth pairings
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    # Redirect upower histograms for battery life prediction
    "L /var/lib/upower - - - - /persist/var/lib/upower"
    # Redirect LXD container info
    "L /var/lib/lxd - - - - /persist/var/lib/lxd"
    # Redirect docker container info
    "L /var/lib/docker - - - - /persist/var/lib/docker"
    # Redirect libvirt VM info and storage
    "L /var/lib/libvirt - - - - /persist/var/lib/libvirt"
    # Redirect account info service
    "L /var/lib/AccountsService - - - - /persist/var/lib/AccountsService"
    # Redirect the actual NixOS config directory
    "L /var/lib/AccountsService - - - - /persist/var/lib/AccountsService"
  ];

  # Redirect SSH host keys
  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Add ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  # ZFS services
  services.zfs.autoSnapshot.enable = true;
  # ZFS scrubbing, but only on AC power
  services.zfs.autoScrub.enable = true;
  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;
  # ZFS trim, but also only on AC
  services.zfs.trim.enable = true;
  systemd.services.zpool-trim.unitConfig.ConditionACPower = true;

  # Allegedly, ZFS does not like the kernel scheduler messing with it
  # TODO: Research how to set this only for /dev/sda
  boot.kernelParams = [ "elevator=none" ];
}
