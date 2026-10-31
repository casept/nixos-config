{ environment, lib, pkgs, services, ... }:
let
  hardeningBase = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = "read-only";
    PrivateTmp = true;
    PrivateDevices = true;
    RestrictNamespaces = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@known"
      "~@clock"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@module"
      "~@mount"
      "~@obsolete"
      "~@raw-io"
      "~@reboot"
      "~@swap"
    ];
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectControlGroups = true;
    UMask = "0077";
  };

  # NixOS gives units defined here a minimal PATH (coreutils/findutils/...).
  # Third-party units that exec helpers by name need the normal paths back.
  servicePath = "/run/wrappers/bin:/run/current-system/sw/bin";

  mkHardenedService = extra: {
    overrideStrategy = "asDropin";
    serviceConfig = hardeningBase // extra;
  };

  mkSystemService = extra: {
    overrideStrategy = "asDropinIfExists";
    serviceConfig = hardeningBase // extra;
  };

  # Daemons that never spawn arbitrary programs: full sandbox
  mkTightService = extra: {
    overrideStrategy = "asDropin";
    environment.PATH = lib.mkForce servicePath;
    serviceConfig = hardeningBase // {
      CapabilityBoundingSet = "";
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
    } // extra;
  };

  mkPipewireService = extra: {
    overrideStrategy = "asDropin";
    environment.PATH = lib.mkForce servicePath;
    serviceConfig = {
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      PrivateTmp = true;
      PrivateDevices = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      CapabilityBoundingSet = "";
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_NETLINK"
      ];
      UMask = "0077";
      ReadWritePaths = [ "%t" ];
    } // extra;
  };

  # Services whose helper children are known
  mkMediumService = extra: {
    overrideStrategy = "asDropin";
    environment.PATH = lib.mkForce servicePath;
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateTmp = false;
      PrivateDevices = false;
      RestrictNamespaces = false;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
        "%h/.local/share"
        "%h/.local/state"
      ];
    } // extra;
  };
in
{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # Don't use these
    elisa
    # For some reason env activation after rebuild gets blocked until index completes
    baloo
  ];

  programs.kdeconnect.enable = true;

  environment.systemPackages = [
    # Latest git master, includes fixes not yet in a tagged release
    (pkgs.unstable.callPackage ../pkgs/krohnkite { })
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.discover
    pkgs.kdePackages.partitionmanager
    pkgs.kdePackages.kconfig
    (pkgs.callPackage ../pkgs/kwin6-bismuth-decoration { })
    # Most distros call this qdbus6, create symlink so I can keep scripts portable
    (pkgs.writeShellScriptBin "qdbus6" "exec -a $0 ${pkgs.kdePackages.qttools}/bin/qdbus $@")
    (pkgs.writeShellScriptBin "qdbus-qt6" "exec -a $0 ${pkgs.kdePackages.qttools}/bin/qdbus $@")
  ];

  systemd.user.services = {
    plasma-polkit-agent = mkHardenedService {
      PrivateDevices = false;
      RestrictAddressFamilies = [ "AF_UNIX" ]; # Wayland, D-Bus
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    kunifiedpush-distributor = mkHardenedService {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      ReadWritePaths = [
        "%t"
        "%h/.cache"
        "%h/.config"
      ];
    };

    # Parses untrusted files
    kde-baloo = mkHardenedService {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_NETLINK"
      ];
      ReadWritePaths = [
        "%t"
        "%h/.cache"
        "%h/.local/share/baloo"
      ];
    };

    drkonqi-sentry-postman = mkHardenedService {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    # Weekly cleanup only removes stale metadata under ~/.cache/kcrash-metadata
    drkonqi-coredump-cleanup = mkHardenedService {
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    obex = mkHardenedService {
      PrivateTmp = false; # For sending from /tmp
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_BLUETOOTH"
      ];
      ReadWritePaths = [
        "%t"
        "%T"
        "%h/.cache"
      ];
    };

    plasma-powerdevil = mkHardenedService {
      PrivateDevices = false;
      ProtectKernelTunables = false; # Backlight etc.
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_NETLINK" # udev
      ];
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
      ];
    };

    # Needs nothing beyond D-Bus and the runtime directory
    plasma-kwallet-pam = mkHardenedService {
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [ "%t" ];
    };

    # Only talks to KWin over D-Bus and writes kglobalshortcutsrc
    plasma-kglobalaccel = mkHardenedService {
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
      ];
    };

    ssh-agent = mkSystemService {
      PrivateTmp = false;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [ "%t" ];
    };

    geoclue-agent = mkSystemService {
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [ "%t" ];
    };

    speech-dispatcher = mkHardenedService {
      RestrictAddressFamilies = [ "AF_UNIX" ];
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    dconf = mkTightService {
      # writes ~/.config/dconf/user; no cache directory is used
      ReadWritePaths = [
        "%t"
        "%h/.config"
      ];
    };

    at-spi-dbus-bus = mkTightService {
      ReadWritePaths = [ "%t" ];
    };

    xdg-permission-store = mkTightService {
      # Permissions under ~/.local/share/flatpak/db
      ReadWritePaths = [
        "%t"
        "%h/.local/share"
      ];
    };

    plasma-kactivitymanagerd = mkTightService {
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
        "%h/.local/share"
        "%h/.local/state"
      ];
    };

    # Only exposes GTK menu models over D-Bus
    plasma-gmenudbusmenuproxy = mkTightService {
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    plasma-xembedsniproxy = mkTightService {
      PrivateTmp = false;
      ReadWritePaths = [
        "%t"
        "%h/.cache"
      ];
    };

    plasma-baloorunner = mkTightService {
      ReadWritePaths = [
        "%t"
        "%h/.local/share/baloo"
      ];
    };

    plasma-kaccess = mkTightService {
      PrivateTmp = false;
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
      ];
    };

    pipewire = mkPipewireService {
      PrivateDevices = false; # /dev/snd/controlC*, pcmC*, seq
      ReadWritePaths = [
        "%t"
        "-%h/.config/pipewire"
        "-%h/.local/state/pipewire"
      ];
    };

    pipewire-pulse = mkPipewireService {
      ReadWritePaths = [
        "%t"
        "-%h/.config/pulse"
      ];
    };

    wireplumber = mkPipewireService {
      PrivateDevices = false; # /dev/snd/controlC*
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_NETLINK"
        "AF_BLUETOOTH"
      ];
      ReadWritePaths = [
        "%t"
        "-%h/.config/wireplumber"
        "%h/.local/state/wireplumber"
      ];
    };

    plasma-kded6 = mkMediumService {
      PrivateDevices = false; # /dev/rfkill and /dev/dri/renderD128
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      ReadWritePaths = [
        "%t"
        "%h/.config"
        "%h/.cache"
        "%h/.local/share"
        "%h/.local/state"
        # Browser integration with Flatpak apps
        "-%h/.var/app"
      ];
    };

    plasma-xdg-desktop-portal-kde = mkMediumService {
      ProtectHome = false;
      PrivateDevices = false; # /dev/dri for ScreenCast/Screenshot
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
    };
  };
}
