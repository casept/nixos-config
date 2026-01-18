{ pkgs, home-manager, ... }: {

  imports = [
    ./transmission.nix
    ./jellyfin.nix
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  programs.mosh.enable = true;

  time.timeZone = "Europe/Berlin";

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };


  environment.systemPackages = with pkgs; [
    # Backup
    rclone
    unstable.rustic
  ];

  # Enable zsh properly
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.casept = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.casept = ../home.nix;

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.settings.trusted-users = [ "root" "casept" ];
  security.sudo.wheelNeedsPassword = false;

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "lv_LV.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 8384 ];

  # Imperative containers
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;

  # User shared by multimedia services
  users.groups.media = { };
  users.users.media = {
    isNormalUser = false;
    isSystemUser = true;
    description = "Shared user for multimedia services";
    group = "media";
  };
}
