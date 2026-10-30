{ config, lib, ... }:
let
  hardening = {
    CapabilityBoundingSet = [
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_ADMIN" # btrfs qgroup ioctls
    ];
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = "read-only";
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    ReadWritePaths = [ "-/.snapshots" "-/home/.snapshots" ];
    # AF_UNIX for the D-Bus socket, AF_NETLINK for libudev/nss lookups.
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_NETLINK"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
    UMask = "0077";
  };
in
{
  config = lib.mkIf (config.services.snapper.configs != { }) {
    systemd.services.snapper-timeline.serviceConfig = hardening;
    systemd.services.snapper-cleanup.serviceConfig = hardening;
  };
}
