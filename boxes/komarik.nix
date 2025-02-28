{ pkgs, ... }: {
  imports = [ ../workstation ../builders.nix ../hardware/micropc.nix ];

  # I like systemd, fite me
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;

  networking.hostName = "komarik";
  networking.hostId = "ef3d24fd";

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Configure filesystems
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/4f171c5e-306d-4752-bd4b-7ec20b2a7a2b";
  fileSystems =
    let
      btrfsCommon = [ "defaults" "compress=zstd:1" "autodefrag" ];
      id = "/dev/disk/by-uuid/1724ce47-b4b7-4565-b14a-0dbccdec3dd8";
    in
    {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-uuid/1C47-35C5";
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
      "/nix" = {
        fsType = "btrfs";
        device = id;
        options = btrfsCommon ++ [ "noatime" "subvol=nix" ];
      };
    };

  # Add BTRFS support
  boot.supportedFilesystems = [ "btrfs" ];
  # BTRFS scrubbing, but only on AC power
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    # Will scrub all subvols on FS
    fileSystems = [ "/" ];
  };
  systemd.services.btrfs-scrub.unitConfig.ConditionACPower = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  # Better HW support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" ];

  # Keyboard lacks Alt-Gr, making EURKey difficult to use
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          rightshift = "rightalt";
        };
      };
    };
  };
}
