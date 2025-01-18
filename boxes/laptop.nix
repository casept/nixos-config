{ pkgs
, lib
, nixpkgs
, nixpkgs-unstable
, nixos-hardware
, home-manager
, comma
, nixos-vsliveshare
, ...
}: {

  imports = [ ../workstation/workstation.nix ../hardware/t14.nix ];

  # I like systemd, fite me
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;

  networking.hostName = "laptop";
  networking.hostId = "8aa2b679";

  # See https://grahamc.com/blog/erase-your-darlings for rationale behind this setup

  # / is wiped on every boot to keep unmanaged state under control
  fileSystems."/" = {
    device = "rpool/expendable/wipedonboot";
    fsType = "zfs";
  };
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/expendable/wipedonboot@blank
  '';

  fileSystems."/nix" = {
    device = "rpool/expendable/nix";
    fsType = "zfs";
  };

  # This is where precious system state outside /home is stored
  fileSystems."/persist" = {
    device = "rpool/precious/systempersist";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/precious/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/541E-6256";
    fsType = "vfat";
  };

  # Remember connected networks and their creds
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  # Remember Mullvad credentials and config
  environment.etc."mullvad-vpn" = { source = "/persist/etc/mullvad-vpn/"; };

  # Remember NixOS configuration
  environment.etc."nixos" = { source = "/persist/etc/nixos/"; };

  # Remember user credentials
  environment.etc."shadow" = { source = "/persist/etc/shadow"; };
  environment.etc."shadow-" = { source = "/persist/etc/shadow-"; };

  # For services where state location can't be changed in the config, we use symlinks
  systemd.tmpfiles.rules = [
    # Remember Bluetooth pairings
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    # TODO: Upower doesn't seem to like the symlink, reenable once I figure out a fix
    # Remember upower histograms for battery life prediction
    # "L /var/lib/upower - - - - /persist/var/lib/upower"
    # Remember LXD containers
    "L /var/lib/lxd - - - - /persist/var/lib/lxd"
    # Remember docker containers
    "L /var/lib/docker - - - - /persist/var/lib/docker"
    # Remember root's home (needed to keep system channels)
    "L /root - - - - /persist/root"
    # Remember users who completed the sudo lecture so it doesn't repeat after every boot
    "L /var/db/sudo/lectured - - - - /persist/var/db/sudo/lectured"
  ];

  # Remember SSH host keys
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
  # TODO: Research how to set this only for /dev/nmvme0n1p2
  boot.kernelParams = [ "elevator=none" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
