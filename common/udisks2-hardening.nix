{ config, lib, pkgs, ... }:
let
  # Forbid anyone except administrative users from talking to udisks at all
  dbusPolicyText = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
     "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    <busconfig>
      <!-- Default policies are applied before group/user policies, so this
           denies everyone first and the rules below punch holes for wheel
           and root. -->
      <policy context="default">
        <deny send_destination="org.freedesktop.UDisks2"/>
      </policy>

      <policy group="wheel">
        <allow send_destination="org.freedesktop.UDisks2"/>
      </policy>

      <policy user="root">
        <allow send_destination="org.freedesktop.UDisks2"/>
      </policy>
    </busconfig>
  '';

  dbusPolicy = pkgs.runCommand "udisks2-wheel-only-dbus-policy" { } ''
    mkdir -p $out/etc/dbus-1/system.d \
             $out/share/dbus-1/system.d \
             $out/share/dbus-1/system-services
    cp ${pkgs.writeText "99-udisks2-wheel-only.conf" dbusPolicyText} $out/share/dbus-1/system.d/99-udisks2-wheel-only.conf
  '';

  hardening = {
    NoNewPrivileges = true;

    CapabilityBoundingSet = [
      # Mount points in /run/media/$USER belong to the calling user.
      "CAP_CHOWN"
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_FOWNER"
      # libblockdev mounts "user"/"users" fstab entries as that user.
      "CAP_SETGID"
      "CAP_SETUID"
      # mount/umount, swap, loop devices and device-mapper ioctls.
      "CAP_SYS_ADMIN"
      # SMART/SG_IO.
      "CAP_SYS_RAWIO"
    ];

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_NETLINK"
    ];
    IPAddressDeny = "any";

    ProtectSystem = "strict";
    # Mount dirs
    ReadWritePaths = [
      "/run"
      "/var/lib/udisks2"
      "-/media"
    ];
    ProtectHome = "read-only";

    PrivateTmp = true;
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
    SystemCallFilter = [
      "@system-service"
      "@mount"
      "@swap"
    ];
  };
in
{
  config = lib.mkIf config.services.udisks2.enable {
    systemd.services.udisks2.serviceConfig = hardening;

    # Restrict access to the bus name itself, not just individual methods.
    services.dbus.packages = lib.mkAfter [ dbusPolicy ];

    # Require auth for most things to limit impact of 0-click
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.udisks2.") !== 0)
          return polkit.Result.NOT_HANDLED;

        var exempt = [
          "org.freedesktop.udisks2.ata-check-power",
          "org.freedesktop.udisks2.ata-smart-update",
          "org.freedesktop.udisks2.ata-standby",
          "org.freedesktop.udisks2.ata-standby-system",
          "org.freedesktop.udisks2.ata-standby-other-seat",
          "org.freedesktop.udisks2.cancel-job",
          "org.freedesktop.udisks2.nvme-smart-update",
          "org.freedesktop.udisks2.rescan"
        ];

        if (exempt.indexOf(action.id) !== -1)
          return polkit.Result.NOT_HANDLED;

        return polkit.Result.AUTH_ADMIN_KEEP;
      });
    '';
  };
}
