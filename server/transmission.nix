{ pkgs, ... }: {
  # networking.firewall.allowedUDPPorts = [ 443 ]; # For reaching Mullvad
  # Server de-ber-wg004, config for device "Aware Dog"
  networking.wg-quick.interfaces.mullvad0 = {
    autostart = true;
    address = [ "10.75.113.146/32" "fc00:bbbb:bbbb:bb01::c:7191/128" ];
    dns = [ "10.64.0.1" ];
    privateKeyFile = "/root/mullvad0_private_key";
    peers = [
      {
        persistentKeepalive = 25;
        endpoint = "193.32.248.69:443";
        allowedIPs = [ "0.0.0.0/0" "::0/0" ];
        publicKey = "6PchzRRxzeeHdNLyn3Nz0gmN7pUyjoZMpKmKzJRL4GM=";
      }
    ];
  };

  containers.transmission = {
    autoStart = true;
    privateNetwork = true;
    # FIXME: For some reason, the interface does not come up
    # interfaces = [ "mullvad0" ];

    bindMounts = {
      "/torrents" = {
        hostPath = "/tank/torrents";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.11";

      services.transmission = {
        enable = true;
        home = "/var/lib/transmission";
        settings = {
          port-forwarding-enabled = false;
        };
      };

      # Cursed workaround for https://github.com/NixOS/nixpkgs/issues/258793
      systemd.services.transmission.serviceConfig = {
        RootDirectoryStartOnly = lib.mkForce false;
        RootDirectory = lib.mkForce "";
        PrivateMounts = lib.mkForce false;
        PrivateUsers = lib.mkForce false;
      };
    };
  };
}
