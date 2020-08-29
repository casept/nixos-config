{ config, pkgs, ... }: {
  system.stateVersion = "20.03";
  services.nextcloud = {
    enable = true;
    home = "/persist";
    config.adminpassFile = "/adminpass";
    autoUpdateApps.enable = true;
    hostName = "casept.dynv6.net";
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];
}
