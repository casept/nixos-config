{ pkgs, ... }: {
  imports = [ ../workstation/workstation.nix ../hardware/z440.nix ];

  # I like systemd, fite me
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.systemd-boot.editor = false;

  networking.hostName = "clobus";
  networking.hostId = "07bfa1ff";

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Configure filesystems
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/a577451b-e824-47c9-a2f0-5bb611c02c67";
  fileSystems =
    let
      btrfsCommon = [ "defaults" "compress=zstd:1" "autodefrag" ];
      id = "/dev/disk/by-uuid/5b29964e-9edb-4d28-bf52-fc684438bd93";
    in
    {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-uuid/C92B-5AC1";
        neededForBoot = true;
        options = [ "umask=022" ];
      };
      "/" = {
        fsType = "btrfs";
        device = id;
        options = btrfsCommon ++ [ "subvol=root" ];
      };
      "/home" = {
        fsType = "btrfs";
        device = id;
        options = btrfsCommon ++ [ "subvol=home" ];
      };
    };

  # Add BTRFS support
  boot.supportedFilesystems = [ "btrfs" ];
  # BTRFS scrubbing
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    # Will scrub all subvols on FS
    fileSystems = [ "/" ];
  };

  # Automatic BTRFS snapshots
  services.snapper = {
    persistentTimer = true;
    cleanupInterval = "1d";
    configs.home = {
      # Snapshot just enough to recover from overzealous rm usage
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "casept" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_DAILY = 1;
      TIMELINE_LIMIT_HOURLY = 2;
    };
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  # Better HW support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Permit unlocking the root drive remotely after netboot
  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    systemd.users.root.shell = "/bin/cryptsetup-askpass";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJPSyPY5YwoFRbuijaSHsUY4CAQH/e3lRslTrt0wFUT user@casept-x230t" ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };

  # Configure the machine as a remote builder
  # Setting up the SSH keys is not done here
  users.users.nixremote = {
    isNormalUser = true;
    home = "/home/nixremote";
    description = "Unprivileged user for remote builds";
    group = "nogroup";
  };
  services.displayManager.hiddenUsers = [ "nixremote" ];
}
