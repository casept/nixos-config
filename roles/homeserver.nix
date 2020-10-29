# The top-level config deployed on the host.
# Services are run as NixOS containers.
{ pkgs, ... }: {
  # Running this on the host is less work than in a container
  imports = [ ./subroles/server/wireguard-server.nix ];

  system.stateVersion = "20.03";

  # Prevent the drive from filling up with too many old generations
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  # This server is not exactly "production", and I'd rather not get pwned
  system.autoUpgrade.enable = true;
  # The system won't come up without manual intervention due to having to manually enter decryption passwords
  system.autoUpgrade.allowReboot = false;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Passwordless sudo
  security.sudo.extraConfig = ''
    %wheel         ALL = (ALL) NOPASSWD: ALL
  '';
  # TODO: Remove
  environment.systemPackages = [ pkgs.git ];

  # Admin user
  programs.zsh.enable = true;
  users.users.user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    createHome = true;
    home = "/home/user";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2rqIQyFmQPgv11ABOoOvNycHz1eHu+sCMYN9XfQeFtaFJlz0MSxwYDOdqfLTuFwMaNiQqxVeES/unNa/YqKtTtclUgme/c6kqxh8+JaOI3dDSQQoA5Kgg5TVRiTue46ojOL766nty1L6SrJ7ivrJF+4g5Vrbocim1dN5tPsLCeOdsV6Nr9UxwlI7yTQb5hOo9EC/iZrExVqUthn5XzjiPaERDcCYeqdb/1sFeMqv4QWwTlk9mMGRxUoWyJa12XiLwlB5MMvN4IW+NyVbs82SA3hc45vBFHwaLDymsYoMby4wdL6fLAGNoi5fuyfG1iOPG5eArs8oeN+INLoZzu8OLLqQwPMIUqrzwoB+MBDzkbj37z1C3k8zMhSQesO4ZYP/huhJW24SwQrK7pNMCSais2HLvt/cR3QlMfShBkxeBnIkkIzXZXSHyxr3aGCyY0VpmHXz92gmfVq+pnVCOBpowTBtM/scHqroZYzMchqPtlJSECgzRFLrcV4BUAQzkUnVHFkR/zejuOc0Nd45NteU7SapZUq2jJGO6qS75iYy+I5n/Ta0r23vhU9o5L2A+qj0CeAIZCbuizHGRB76QFOIrzRE1xvZ6Eeqiz7pKoci9+BiOQfweisQh7dz3kfUrvpEvys2CryF+DnZf5ygVGTbOK02tpNlLrUCF8DV38e2aBQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkDqwoQOFjp8LsOuCov9Mb0mlFZvkG1jj48cEdR5Tdozp9y92fdsf33C1cJAa5jtFVqYX8EydyFrMhjRRY7qd89QIAgB33IsOoGmM2XFxy9q7X0fAfojvkU9nil3GQfL1OexliuW1LOipXo3s1Ay7HNyruQvJqCfp/LNeTn4EwTOIg6vsCZLxw+T2Snrl1slGqp/mk0xSiq9t81qGKXouqLQECCmX4zAvp4wA8Fq7cHqtfOX26L1nRAsVRP93WOUXrkc0nL5vP9DF+uQaOtj0rA/F3qtgkh+zxvqS4iUC/d932dVayS2+UtR1HhAY/1L7E+9StxCDX5vgP+YJ0a4PzZDBaEhhznrna1cSsWh10ErlPdqMwgrk6+d7/V78Lk3z36vLkNMz+v6/T60vmHUp3/6w/ZonMmuyIESnhLt9e42AZQeElrVtiOedu1XbiBw9c9ztw+/NBKESFuAIcVQaeKo+MiE4f7m8/APWPHNboHqF6G1fMFsjtDNSGGx1nGCECCSMO/EJbxwpWGzn7a4DWq0wRZFYpwrZ6/w3Ex9VL6QiqbkKXVmNSTMkSXMBupzQBbxQX6Pxk4DCPC4ptgGApfIxTH6hUpnvsrzqBIiAiwekGdEJ9QVNifo73s9DeYmieBprpJPDi6SsIhf+/BcHQnQeEL7eNJBEKvc7FEYWr2Q=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfzPJMY90AZhPIQWSjqTc3AxE0zRepOil3rIWUzfBjDc+PAT1TmVCzBaXkkPEL7aEFyvAfbHCPB9lngW7kn7eSckxP6NCuf3kNy/uTUojpi4n6uNnSMufSNRpvE6ZgMaCmpP2MumkACsQwe9tjuwps2WRwdk0mI7BuYfG7Dod5nYR2af4GyBc992Y0+2Wk+osZ2njCKqRSgg3IZRmCmAxAfr8tJtmzE/z9BXF5LqghC0JtBbO6I8R2NjFxL3L28CtBLC2IZpum2MRBLfFxFpQs4J97loz4TRa8XaSloIRQIgfEPI9JF1mkJpgEdX9sMNZ82rNPU1xM4LoDDdx8xjBtMvZMDN7nwuh8+IFYzB58/1wMXO9SPjLKZzM7VpfWr4t8QePWzKOZTlD/0x4zdUfCBbo0Pnxk3/C0dZo4SnwXhNhhoJEsxCsDqYozrO+J4A9s0Li5ncWZ36KUE8lhldFSDW8JtJ8pF3HepLswdmg6bIZbe5Z2N7NHU0ygbL5amdLJoX9nPdJhcMsl+35zL0v675DJrIcid3lhdiJjD/FbFVSy5i7t08E9WD25mSukmxPnyJR4onvFsyEI0ZVvo6RIhSr6w1WR//gk9aGHie582L8xHxtwAHetZ4IGNZremrcz17xqAIYC37Qo8uGuwNJmdA3JQMU2h1RXehYW1dQJqQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2rqIQyFmQPgv11ABOoOvNycHz1eHu+sCMYN9XfQeFtaFJlz0MSxwYDOdqfLTuFwMaNiQqxVeES/unNa/YqKtTtclUgme/c6kqxh8+JaOI3dDSQQoA5Kgg5TVRiTue46ojOL766nty1L6SrJ7ivrJF+4g5Vrbocim1dN5tPsLCeOdsV6Nr9UxwlI7yTQb5hOo9EC/iZrExVqUthn5XzjiPaERDcCYeqdb/1sFeMqv4QWwTlk9mMGRxUoWyJa12XiLwlB5MMvN4IW+NyVbs82SA3hc45vBFHwaLDymsYoMby4wdL6fLAGNoi5fuyfG1iOPG5eArs8oeN+INLoZzu8OLLqQwPMIUqrzwoB+MBDzkbj37z1C3k8zMhSQesO4ZYP/huhJW24SwQrK7pNMCSais2HLvt/cR3QlMfShBkxeBnIkkIzXZXSHyxr3aGCyY0VpmHXz92gmfVq+pnVCOBpowTBtM/scHqroZYzMchqPtlJSECgzRFLrcV4BUAQzkUnVHFkR/zejuOc0Nd45NteU7SapZUq2jJGO6qS75iYy+I5n/Ta0r23vhU9o5L2A+qj0CeAIZCbuizHGRB76QFOIrzRE1xvZ6Eeqiz7pKoci9+BiOQfweisQh7dz3kfUrvpEvys2CryF+DnZf5ygVGTbOK02tpNlLrUCF8DV38e2aBQ=="
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.user = ../home.nix;

  # We want mainline wireguard support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # TODO: Backups via restic and rclone

  # NixOS container config
  boot.enableContainers = true;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ]; # Names of container ifaces
  networking.nat.externalInterface = "eth0"; # TODO: Get primary iface name here
  containers.media = {
    config = import ./subroles/server/media-server.nix;
    # Mount in the wireguard key
    bindMounts = {
      "/root/wg-key" = {
        hostPath = "/root/wg-key";
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.234.98.1";
    # FIXME: changing this breaks wireguard ATM
    localAddress = "10.234.98.2";
    forwardPorts = [
      # Transmission webUI
      {
        protocol = "tcp";
        hostPort = 9091;
        containerPort = 9091;
      }
      # Jellyfin webUI
      {
        protocol = "tcp";
        hostPort = 8096;
        containerPort = 8096;
      }
      # Jellyfin discovery
      {
        protocol = "udp";
        hostPort = 1900;
        containerPort = 1900;
      }
      {
        protocol = "udp";
        hostPort = 7359;
        containerPort = 7359;
      }
    ];

  };
  containers.strelay = {
    config = import ./subroles/server/syncthing-relay.nix;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.234.98.1";
    localAddress = "10.234.98.3";
    forwardPorts = [
      # Syncthing relay proto and stats collection
      {
        protocol = "tcp";
        hostPort = 22067;
        containerPort = 22067;
      }
      {
        protocol = "tcp";
        hostPort = 22070;
        containerPort = 22070;
      }
    ];
  };
  containers.torbridge = {
    config = import ./subroles/server/tor-bridge.nix;
    autoStart = true;
    privateNetwork = false;
  };

  # Create an SSH hidden service in order to enable login in case dynamic DNS fails
  containers.torssh = {
    config = {
      system.stateVersion = "20.03";
      services.tor.enable = true;
      services.tor.hiddenServices = {
        ssh = {
          name = "ssh";
          version = 3;
          map = [{
            port = "22";
            toHost = "localhost";
            toPort = "22";
          }];
        };
      };
    };
    bindMounts = {
      "/var/lib/tor" = {
        hostPath = "/var/lib/torssh";
        isReadOnly = false;
      };
    };
    autoStart = true;
    privateNetwork = false;
    ephemeral = true;
  };

  containers.zeronet = {
    config = import ./subroles/server/zeronet.nix;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.234.98.1";
    localAddress = "10.234.98.4";
    forwardPorts = [
      # Zeronet webUI
      {
        protocol = "tcp";
        hostPort = 43110;
        containerPort = 43110;
      }
    ];
  };
  containers.gitea = {
    config = import ./subroles/server/gitea.nix;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.234.98.1";
    localAddress = "10.234.98.5";
    forwardPorts = [{
      protocol = "tcp";
      hostPort = 80;
      containerPort = 80;
    }];
  };
  containers.nextcloud = {
    config = import ./subroles/server/nextcloud.nix;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.234.98.1";
    localAddress = "10.234.98.6";
    forwardPorts = [{
      protocol = "tcp";
      hostPort = 80;
      containerPort = 80;
    }];
  };
  containers.ddclient = {
    config = import ./subroles/server/ddclient.nix;
    autoStart = true;
    privateNetwork = false;
    # Mount in the ddclient config file only containing the secret password
    bindMounts = {
      "/etc/ddclient.conf" = {
        hostPath = "/etc/ddclient.conf";
        isReadOnly = true;
      };
    };
  };

  # TODO: Configure Nginx as reverse proxy for TLS

  # Enable LXD host for running other distros on
  virtualisation.lxc.lxcfs.enable = true;
  virtualisation.lxd = {
    enable = true;
    recommendedSysctlSettings = true;
  };
  # TODO: Replace manual `lxd init` with declarative version
}
