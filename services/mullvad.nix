{ pkgs, ... }: {
  boot.kernelModules = [ "tun" ];
  # Required until a nixpkgs PR is merged
  networking.iproute2.enable = true;

  systemd.services.mullvad-daemon = {
    description = "Mullvad VPN daemon";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [
      "network-online.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    path = [
      pkgs.iproute
      # Needed for ping
      "/run/wrappers"
    ];
    serviceConfig = {
      StartLimitBurst = 5;
      StartLimitIntervalSec = 20;
      ExecStart =
        "${pkgs.unstable.mullvad-vpn}/bin/mullvad-daemon -v --disable-stdout-timestamps";
      Restart = "always";
      RestartSec = 1;
    };
  };
}
