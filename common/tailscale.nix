{ ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Load tun at boot so /dev/net/tun can be allow-listed with DeviceAllow= below.
  boot.kernelModules = [ "tun" ];

  # Hardening for tailscaled, adapted from
  # https://tailscale.com/docs/reference/best-practices/device-hardening
  systemd.services.tailscaled.serviceConfig = {
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_SYS_MODULE" ];

    DevicePolicy = "closed";
    DeviceAllow = [ "/dev/net/tun rw" ];

    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateMounts = true;
    ProtectHome = false; # would break Tailscale SSH/Taildrive
    ProtectControlGroups = true;
    ProtectKernelLogs = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@known"
      "~@clock"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@mount"
      "~@obsolete"
      "~@pkey"
      "~@raw-io"
      "~@reboot"
      "~@swap"
    ];

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_PACKET"
    ];

    ProtectSystem = "full";
    ReadWritePaths = [ "-/etc/resolv.conf" ];
  };
}
