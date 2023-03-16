{ config, pkgs, ... }: {
  system.stateVersion = "22.11";
  services.gitea = {
    enable = true;
    stateDir = "/persist";
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
