{ config, ... }:
let
  port = 4433;
  baseUrl = "http://${config.networking.hostName}:${toString port}";
in
{
  services.hister = {
    enable = true;
    inherit port;

    # Contains access token
    environmentFile = "/etc/hister.env";

    settings.server = {
      address = "0.0.0.0:${toString port}";
      base_url = baseUrl;
    };
  };

  # Only expose Hister on loopback (always allowed) and the tailnet.
  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ port ];

  systemd.services.hister.serviceConfig = {
    # In addition to upstream hardening
    DevicePolicy = "closed";
    PrivateIPC = true;
    PrivateMounts = true;
    KeyringMode = "private";
    SocketBindDeny = "any";
    SocketBindAllow = [ "tcp:${toString port}" ];
    SystemCallFilter = [
      "~@clock"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@mount"
      "~@obsolete"
      "~@raw-io"
      "~@reboot"
      "~@swap"
    ];
  };
}
