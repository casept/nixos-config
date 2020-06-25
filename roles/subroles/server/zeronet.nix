{ config, pkgs, ... }: {
  system.stateVersion = "20.03";
  services.zeronet = {
    enable = true;
    port = 43110;
    torAlways = true;
    # Only allows connections from localhost by default
    #settings = { global = { ui_restrict = "0.0.0.0"; }; };
  };
  networking.firewall.allowedTCPPorts = [ 43110 ];
}
