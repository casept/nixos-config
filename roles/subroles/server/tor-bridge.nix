{ config, pkgs, ... }: {
  system.stateVersion = "20.03";
  services.tor.enable = true;
  services.tor.relay = {
    enable = true;
    contactInfo = "davids.paskevics@gmail.com";
    role = "bridge";
    bandwidthRate = 1048576; # 1MiB/s
    bandwidthBurst = 3145728; # 3MiB/s
    port = 143;

  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 143 ];
}
