{ ... }:

{
  systemd.services."btrfs-scrub--".serviceConfig = {
    CapabilityBoundingSet = [
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_ADMIN" # scrub ioctls
    ];
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    PrivateMounts = true;
    ProtectSystem = "full";
    StateDirectory = "btrfs";
    ProtectHome = true;
    ProtectProc = "invisible";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
    # AF_UNIX for the journal, AF_NETLINK for libudev device enumeration.
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_NETLINK"
    ];
    UMask = "0077";
  };
}
