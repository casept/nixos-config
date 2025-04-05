{ pkgs, ... }: {
  # Define VPN network namespace
  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = /. + "/root/mullvad.conf";
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    portMappings = [
      # Make transmission webUI accessible from outside the NS
      { from = 9091; to = 9091; protocol = "tcp"; }
    ];
    # FIXME: Needed?
    #openVPNPorts = [{
    #  port = 443;
    #  protocol = "both";
    #}];
  };

  # Add systemd service to VPN network namespace
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "mullvad";
  };

  services.transmission = {
    enable = true;

    settings = {
      "rpc-bind-address" = "0.0.0.0";
      "rpc-whitelist" = "192.168.0.*";
      "port-forwarding-enabled" = "false";
      "lpd-enabled" = "false";

      "download-dir" = "/tank/torrents";
      "download-queue-enabled" = "false";
    };
  };
}
