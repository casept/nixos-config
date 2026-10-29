{ config, lib, pkgs, ... }:
let
  # Hardening shared by libvirt's daemons. The hypervisor daemons (libvirtd,
  # virtqemud, ...) spawn QEMU, which inherits their sandbox, so these settings
  # have to stay broad.
  virtDaemonHardening = {
    NoNewPrivileges = true;
    ProtectSystem = "full";
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
  };

  # virtlogd only writes QEMU logs below /var/log/libvirt, so it can be locked down hard.
  virtLogdHardening = {
    CapabilityBoundingSet = [
      "CAP_CHOWN"
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_FOWNER"
    ];
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    PrivateMounts = true;
    ProtectSystem = "strict";
    LogsDirectory = [
      "libvirt"
      "libvirt/qemu"
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
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
    RestrictAddressFamilies = [ "AF_UNIX" ];
  };

  # virtlockd opens disk images wherever they live to take locks, so it cannot use ProtectHome or PrivateDevices.
  virtLockdHardening = {
    CapabilityBoundingSet = [
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_FOWNER"
    ];
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateMounts = true;
    ProtectSystem = "full";
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
    RestrictAddressFamilies = [ "AF_UNIX" ];
  };

  # libvirtd plus the modular daemons it can be split into.
  virtDaemons = [
    "libvirtd"
    "virtchd"
    "virtinterfaced"
    "virtlxcd"
    "virtnetworkd"
    "virtnodedevd"
    "virtnwfilterd"
    "virtproxyd"
    "virtqemud"
    "virtsecretd"
    "virtstoraged"
    "virtvboxd"
    "virtxend"
  ];
in
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  systemd.services =
    lib.genAttrs virtDaemons (_: { serviceConfig = virtDaemonHardening; })
    // {
      virtlogd.serviceConfig = virtLogdHardening;
      virtlockd.serviceConfig = virtLockdHardening;
    };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  environment.systemPackages = with pkgs; [ distrobox gnome-boxes ];

  # Creating images for funky architectures
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "mips64-linux"
    "mips64el-linux"
    "mips-linux"
    "mipsel-linux"
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  # services.geoipupdate.enable = true;
}
