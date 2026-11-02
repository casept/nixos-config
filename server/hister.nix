{ config, ... }:
let
  port = 4432;
  publicPort = 4433;
  domain = "${config.networking.hostName}.tail1cdfa.ts.net";
  baseUrl = "https://${domain}:${toString publicPort}";
in
{
  services.hister = {
    enable = true;
    inherit port;

    # Contains access token
    environmentFile = "/etc/hister.env";

    settings.server = {
      address = "127.0.0.1:${toString port}";
      base_url = baseUrl;
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."${domain}:${toString publicPort}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  services.tailscale.permitCertUid = "caddy";
  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ publicPort ];

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
