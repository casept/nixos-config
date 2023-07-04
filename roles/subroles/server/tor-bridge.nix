{ config, pkgs, ... }: {
  system.stateVersion = "23.05";
  services.tor.enable = true;
  services.tor.settings = {
    ContactInfo = "davids.paskevics@gmail.com";
    BandwidthRate = 1048576; # 1MiB/s
    BandwidthBurst = 3145728; # 3MiB/s
    ORPort = 143;
  };
  services.tor.relay = {
    enable = true;
    role = "bridge";
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 143 ];
}
