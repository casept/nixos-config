# Basically a verbatim copy of the in-tree service, except that we use mullvad from unstable.
# TODO: Figure out how to do this in a nicer way with overrides or so
let unstable = import <nixos-unstable> { };

in { config, lib, pkgs, ... }:
let cfg = config.services.mullvad-vpn;
in with lib; {
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
