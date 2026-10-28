{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.lact ];

  systemd.services.lactd = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "on-failure";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      # Needed for gamemode
      ProtectHome = "read-only";
      ProtectKernelTunables = false;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ReadWritePaths = [ "/run" "/tmp" "/etc/lact" ];
      PrivateTmp = false;
      PrivateDevices = false;
      DevicePolicy = "closed";
      DeviceAllow = [
        "char-drm rw"
        "char-kfd rw"
        "char-nvidia rw"
        "char-nvidia-caps rw"
        "/dev/udmabuf rw"
      ];
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_SETGID"
        "CAP_SETUID"
      ];
      AmbientCapabilities = [ ];
      RestrictAddressFamilies = [ "AF_UNIX" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
      SystemCallErrorNumber = "EPERM";
      MemoryDenyWriteExecute = false;
    };
    wantedBy = [ "default.target" ];
  };

  systemd.tmpfiles.rules = [ "d /etc/lact 0755 root root -" ];
}
