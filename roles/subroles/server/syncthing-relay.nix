{ config, pkgs, ... }: {
  system.stateVersion = "20.03";
  services.syncthing.relay = {
    enable = true;
    providedBy = "casept";
    globalRateBps = 1048576;
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22067 22070 ];
}
