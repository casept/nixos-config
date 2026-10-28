{ pkgs, ... }:

{
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    hplipWithPlugin
    samsung-unified-linux-driver
    splix
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
    cups-dymo
    mfcl2700dncupswrapper
    mfcl2700dnlpr
  ];

  services.printing.webInterface = false;

  systemd.tmpfiles.rules = [
    "d /var/lib/cups 0755 root root -"
    "d /var/cache/cups 0770 root lp -"
    "d /var/spool/cups 0710 root lp -"
  ];

  systemd.services.cups.serviceConfig = {
    CapabilityBoundingSet = [
      "CAP_AUDIT_WRITE" # PAM authentication
      "CAP_CHOWN"
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_FOWNER"
      "CAP_FSETID"
      "CAP_KILL" # cancel jobs / kill stuck filters
      "CAP_NET_BIND_SERVICE" # bind 127.0.0.1:631
      "CAP_SETGID"
      "CAP_SETUID"
    ];

    NoNewPrivileges = true;
    PrivateMounts = true;
    ProtectSystem = "strict";
    ReadWritePaths = [
      "/var/lib/cups" # PPDs, TLS certs, printer state
      "/var/cache/cups" # job cache
      "/var/spool/cups" # spooled jobs
      "/run/cups" # control socket
    ];
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
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
  };
}
