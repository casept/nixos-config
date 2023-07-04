{ config, pkgs, ... }: {
  system.stateVersion = "23.05";
  services.zeronet = {
    package = pkgs.zeronet-conservancy;
    enable = true;
    port = 43110;
    torAlways = true;
    # Only allows connections from localhost by default
    #settings = { global = { ui_restrict = "0.0.0.0"; }; };
  };
  networking.firewall.allowedTCPPorts = [ 43110 ];
}
