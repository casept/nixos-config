{ config, pkgs, ... }: {
  system.stateVersion = "23.05";
  services.syncthing.relay = {
    enable = true;
    providedBy = "casept";
    globalRateBps = 1048576;
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22067 22070 ];
}
