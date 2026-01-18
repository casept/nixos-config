{ pkgs, ... }: {
  # Define VPN network namespace
  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = /. + "/root/mullvad.conf";
    accessibleFrom = [
      # LAN
      "192.168.0.0/24"
      # Tailnet
      "100.0.0.0/8"
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
    user = "media";
    group = "media";

    package = pkgs.transmission_4;

    settings = {
      "rpc-bind-address" = "0.0.0.0";
      # Need multiple IP ranges which this doesn't support.
      # Shouldn't matter anyways, as confinement configures a firewall anyways
      "rpc-whitelist-enabled" = "false";
      "rpc-host-whitelist-enabled" = "false";
      "port-forwarding-enabled" = "false";
      "lpd-enabled" = "false";

      "download-dir" = "/nas/torrents";
      "download-queue-enabled" = "false";
    };
  };
}
