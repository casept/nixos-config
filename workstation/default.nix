{ pkgs, hardware, home-manager, systemd, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  programs.mosh.enable = true;

  time.timeZone = "Europe/Berlin";

  imports = [
    ../common/tailscale.nix
    ../common/hardening.nix
    ./cups.nix
    ./dev.nix
    ./flatpak.nix
    ./ops.nix
    ./kde.nix
  ];

  services.mullvad-vpn.enable = true;

  # Allow running dynamically-linked binaries for FHS Linux
  programs.nix-ld.enable = true;

  # Needed for steam and many games.
  hardware.graphics.enable32Bit = true;
  services.pipewire.alsa.support32Bit = true;

  # For Dualshock 3 support
  hardware.bluetooth.package = pkgs.bluez;
  hardware.steam-hardware.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Enable talking to a U2F dongle
  services.udev.extraRules = ''
    ATTRS{idVendor}=="2ccf", ATTRS{idProduct}=="0854", MODE="0660"
  '';
  # Misc. uncategorized packages


  environment.systemPackages = with pkgs; [
    btrfs-assistant
    openconnect
    bleachbit
    waypipe
    # Desktop backup
    rclone
    unstable.rustic
    mosh
    sshuttle
    # The service doesn't put the client into PATH
    mullvad-vpn
  ];

  # Enable zsh properly
  programs.zsh.enable = true;

  # Enable SANE.
  hardware.sane.enable = true;

  services.pipewire.enable = true;
  xdg.portal = {
    enable = true;
  };

  programs.ssh.startAgent = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.casept = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "plugdev"
      "lp"
      "scanner"
      "libvirtd"
      "podman"
      "video"
      "rfkill"
      "wireshark"
    ];

    subUidRanges = [{
      startUid = 100000;
      count = 65536;
    }];
    subGidRanges = [{
      startGid = 100000;
      count = 65536;
    }];
  };

  home-manager.useGlobalPkgs = true;
  # Move conflicting target files aside (e.g. mimeapps.list edited by
  # claude-code's installer) instead of aborting activation.
  home-manager.backupFileExtension = "backup";
  home-manager.users.casept = ../home.nix;

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.settings.trusted-users = [ "root" "casept" ];
  security.sudo.wheelNeedsPassword = false;

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "lv_LV.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    # LC_ALL = "en_US.UTF-8"; # This overrides all other LC_* settings.
    LC_CTYPE = "en_US.UTF8";
    LC_ADDRESS = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
    LC_COLLATE = "de_DE.UTF-8";
  };
}
