{ config, pkgs, ... }: {
  system.stateVersion = "22.11";
  services.ddclient = {
    # The default config file location (/etc/ddclient.conf) must be a ddclient config file only containing the secret.
    # It's not set here so it doesn't end up in the world-readable store.
    enable = true;
    verbose = true;
    protocol = "dyndns2";
    server = "dynv6.com";
    username = "none";
    domains = [ "casept.dynv6.net" ];
  };
}
