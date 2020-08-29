{ config, pkgs, ... }: {
  system.stateVersion = "20.03";
  services.gitea = {
    enable = true;
    stateDir = "/persist";
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
