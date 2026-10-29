{ pkgs, ... }: {
  imports = [
    ../workstation
    ../builders.nix
    ../hardware/z440.nix
    ../common/btrfs.nix
    ../common/lact.nix
  ];

  # I like systemd, fite me
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;

  networking.hostName = "clobus";
  networking.hostId = "07bfa1ff";

  # Wake-on-LAN must not be configured through networking.interfaces.eno1:
  # that implicitly generates 40-eno1.network (DHCP=no), which is also merged
  # into the initrd (because boot.initrd.network.enable is set) and shadows
  # 99-ethernet-dhcp.network there, since networkd uses the first match.
  systemd.network.links."40-eno1" = {
    matchConfig.MACAddress = "a0:8c:fd:d8:b6:48";
    linkConfig.WakeOnLan = "magic";
  };

  # Needed so that nixos-hardware enables CPU microcode updates
  hardware.enableRedistributableFirmware = true;

  # Configure filesystems
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/a577451b-e824-47c9-a2f0-5bb611c02c67";
    crypttabExtraOpts = [ "tries=10" ];
    allowDiscards = true;
  };
  fileSystems =
    let
      btrfsCommon = [ "defaults" "compress=zstd:1" "noatime" ];
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

  boot.supportedFilesystems = [ "btrfs" "zfs" ];
  boot.zfs.forceImportRoot = false;

  boot.tmp.useTmpfs = true;

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

  # Pin for ZFS support
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Hardware-specific tuning utils
  environment.systemPackages = with pkgs; [
    corectrl
  ];

  boot.kernelParams = [
    # Permit AMD GPU overclock
    "amdgpu.ppfeaturemask=0xffffffff"
    # Latency-oriented tuning (costs idle power)
    # Disable NVMe APST so the drive stays in PS0 (removes up to ~4ms wake penalty)
    "nvme_core.default_ps_max_latency_us=0"
  ];

  # Keep the NVMe write path unthrottled (costs a little fairness/latency under
  # mixed load, favours bursty writes).
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/wbt_lat_usec}="0"
  '';

  boot.initrd = {
    systemd = {
      enable = true;
      settings.Manager.DefaultDeviceTimeoutSec = "infinity";
      users.root.shell = "/usr/bin/systemd-tty-ask-password-agent";
      network.networks."99-ethernet-dhcp" = {
        matchConfig = {
          Type = "ether";
          Kind = "!*";
        };
        DHCP = "yes";
      };
    };
    availableKernelModules = [ "e1000e" "igb" ];
    network = {
      enable = true;
      # Ensure it doesn't survive to confuse NetworkManager
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJPSyPY5YwoFRbuijaSHsUY4CAQH/e3lRslTrt0wFUT user@casept-x230t" ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };

  # VR
  services.monado = {
    enable = true;
    defaultRuntime = true;
    # Stock nixpkgs monado lacks the OpenHMD driver, which is the only thing
    # that can drive the original Oculus Rift CV1 (3DoF orientation only).
    # openhmd was removed from nixpkgs, so it is resurrected in ../pkgs/openhmd.
    package = pkgs.monado.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ (pkgs.callPackage ../pkgs/openhmd { }) ];
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
        (pkgs.lib.cmakeBool "XRT_BUILD_DRIVER_OHMD" true)
      ];
    });
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraProfile = ''
        # Allows Monado/WiVRn to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      '';
    };
  };

  # For downloading hand tracking data
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}

