# This seems to not yet be in stable, which is why it's copied here.
let unstable = import <nixos-unstable> { };
in { config, lib, pkgs, ... }: {
  config = {
    boot.kernelModules = [ "tun" ];

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
          "${unstable.pkgs.mullvad-vpn}/bin/mullvad-daemon -v --disable-stdout-timestamps";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}
