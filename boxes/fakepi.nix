{ pkgs, lib, ... }: {
  imports = [ ../server ../builders.nix ../hardware/t14.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "fakepi";
  networking.hostId = "7c4ead44";

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5250-6C0C";
    fsType = "vfat";
    neededForBoot = true;
    options = [ "fmask=0077" "dmask=0077" "defaults" ];
  };

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Add ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "monthly"; # Tank is slow
  services.zfs.trim.enable = true;

  # Allegedly, ZFS does not like the kernel scheduler messing with it
  boot.kernelParams = [ "elevator=none" ];

  # Host-specific networking config
  networking = {
    useDHCP = false;
    bridges."br0" = {
      interfaces = [ "enp7s0f4u2c2" ];
    };
    interfaces.br0.ipv4.addresses = [
      {
        address = "192.168.31.200";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.31.1";
    nameservers = [ "192.168.31.1" ];
  };

  # Magic to disable the lid switch
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Force minimum brightness to save power
  systemd.services = {
    "dim-screen" = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo 0 > /sys/class/backlight/amdgpu_bl1/brightness'";
      };
    };
  };
}
