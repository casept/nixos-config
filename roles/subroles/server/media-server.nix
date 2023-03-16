{ config, pkgs, ... }:
let
  jellyfin_http_port = 8096;
  jellyfin_service_discovery_port = 1900;
  jellyfin_client_discovery_port = 7359;
  transmission_rpc_port = 9091;
  # Must be forwarded by your VPN provider
  transmission_peer_port = 16651;
  # User that all this stuff runs under
  media_user = "media";
  media_group = "media";
in {
  system.stateVersion = "22.11";
  networking.firewall.enable = true;
  # VPN
  networking.nameservers = [ "193.138.218.74" ];
  networking.wireguard = { enable = true; };
  networking.wireguard.interfaces = {
    # This is a configuration for the Latvian Mullvad server.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.67.123.231/32" "fc00:bbbb:bbbb:bb01::4:7be6/128" ];

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/root/wg-key";

      # Killswitch as given in Mullvad config
      # As well as a workaround for routing loops, see https://wiki.archlinux.org/index.php/WireGuard#Known_issues
      # FIXME: This is very ugly and assumes a very particular network setup.
      # Consider calculating how to exclude server from allowedIPs instead.
      preSetup =
        "iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT";
      postSetup = "ip route add 31.170.22.15 via 10.234.98.1 dev eth0";
      postShutdown =
        "ip route del 31.170.22.15 via 10.234.98.1 dev eth0 && iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT";
      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "889sMm3aPBqCae6b74/wrpcF03dDyyMqoUjsHWt+QQ8=";

          # Forward all traffic via VPN (except LAN traffic).
          allowedIPs = [
            "0.0.0.0/5"
            "8.0.0.0/7"
            "11.0.0.0/8"
            "12.0.0.0/6"
            "16.0.0.0/4"
            "32.0.0.0/3"
            "64.0.0.0/2"
            "128.0.0.0/3"
            "160.0.0.0/5"
            "168.0.0.0/6"
            "172.0.0.0/12"
            "172.32.0.0/11"
            "172.64.0.0/10"
            "172.128.0.0/9"
            "173.0.0.0/8"
            "174.0.0.0/7"
            "176.0.0.0/4"
            "192.0.0.0/9"
            "192.128.0.0/11"
            "192.160.0.0/13"
            "192.169.0.0/16"
            "192.170.0.0/15"
            "192.172.0.0/14"
            "192.176.0.0/12"
            "192.192.0.0/10"
            "193.0.0.0/8"
            "194.0.0.0/7"
            "196.0.0.0/6"
            "200.0.0.0/5"
            "208.0.0.0/4"
            "8.8.8.8/32"
            "::0/0"
          ];

          # Set this to the server IP and port.
          endpoint = "193.27.14.146:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;

        }
      ];
    };
  };

  # Configure the service user
  users.users.media_user = {
    isSystemUser = true;
    home = "/var/media";
    name = media_user;
    group = media_group;
  };
  users.groups.media.name = media_group;

  # Configure transmission
  services.transmission = {
    enable = true;
    home = "/var/lib/transmission";
    settings = {
      # TODO: Put behind TLS terminator and bind to localhost
      rpc-whitelist = "127.0.0.1,*.*.*.*";
      user = media_user;
      group = media_group;
      peer-port = transmission_peer_port;
      port-forwarding-enabled = false;
    };
  };

  # configure sonarr
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = media_user;
    group = media_group;
  };

  # configure radarr
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = media_user;
    group = media_group;
  };

  # configure jackett
  services.jackett = {
    enable = true;
    openFirewall = true;
    user = media_user;
    group = media_group;
  };

  # configure jellyfin
  services.jellyfin = {
    enable = true;
    user = media_user;
    group = media_group;
  };

  # Firewall config
  networking.firewall.allowedTCPPorts =
    [ transmission_rpc_port jellyfin_http_port ];
  networking.firewall.allowedUDPPorts =
    [ jellyfin_service_discovery_port jellyfin_client_discovery_port ];

  # For debugging
  environment.systemPackages = with pkgs; [
    stdenv
    bash
    coreutils
    htop
    curl
    wget
    tcpdump
  ];
}
