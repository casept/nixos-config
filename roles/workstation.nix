{ pkgs, hardware, home-manager, nixos-vsliveshare, systemd, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.PasswordAuthentication = false;

  time.timeZone = "Europe/Berlin";

  imports = [
    ../builders.nix
    ./subroles/workstation/dev.nix
    ./subroles/workstation/ops.nix
    ./subroles/workstation/kde.nix
  ];

  services.mullvad-vpn.enable = true;

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  services.pipewire.alsa.support32Bit = true;

  # For Dualshock 3 support
  hardware.bluetooth.package = pkgs.bluez;
  hardware.steam-hardware.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Enable talking to a U2F dongle
  services.udev.extraRules =
    "ATTRS{idVendor}''=''\"2ccf''\", ATTRS{idProduct}''=''\"0854''\", MODE=''\"0660''\"";

  # Misc. uncategorized packages


  environment.systemPackages = with pkgs; [
    openconnect
    bleachbit
    # Desktop backup
    pkgs.rclone
    # Stable does not support new bitlocker versions
    (callPackage ../pkgs/dislocker-master { })
    pkgs.restic
    # The service doesn't put the client into PATH
    mullvad-vpn
  ];

  # Enable zsh properly
  programs.zsh.enable = true;

  #Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    hplipWithPlugin
    samsung-unified-linux-driver
    splix
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
    cups-dymo
    mfcl2700dncupswrapper
    mfcl2700dnlpr
  ];

  # Enable SANE.
  hardware.sane.enable = true;

  services.pipewire.enable = true;
  xdg.portal = {
    enable = true;
  };

  # Enable flatpak support
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };


  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.casept = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "plugdev"
      "adbusers"
      "lp"
      "scanner"
      "vboxusers"
      "video"
      "rfkill"
      "wireshark"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.casept = ../home.nix;

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.settings.trusted-users = [ "root" "casept" ];

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;
}
