{ config, pkgs, ... }: {
  # TODO: Support IPv6 properly
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.wireguard.interfaces.wg0 = {
    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.42.0/24 -o eth0 -j MASQUERADE
    '';

    # This undoes the above command
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.42.0/24 -o eth0 -j MASQUERADE
    '';

    ips = [ "192.168.42.1/24" ];
    privateKeyFile = "/root/wg-key";
    listenPort = 51820;
    peers = [{
      allowedIPs = [ "192.168.42.2/32" ];
      publicKey = "CiEyx82EHuibAc4AvB+BRbTVh9p1mDNIhBQ64mWUMA8=";
    }];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
