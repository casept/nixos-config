{ pkgs, hardware, home-manager, nixos-vsliveshare, rnix-lsp-flake, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.PasswordAuthentication = false;

  time.timeZone = "Europe/Berlin";

  imports = [
    ../builders.nix
    ./subroles/workstation/dev.nix
    ./subroles/workstation/ops.nix
    ./subroles/workstation/gnome.nix
  ];

  services.mullvad-vpn.enable = true;

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  services.pipewire.alsa.support32Bit = true;

  # For Dualshock 3 support
  hardware.bluetooth.package = pkgs.bluezFull;
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
    virt-manager
    # Required for proper QT sway support
    qt5.qtwayland
    # The service doesn't put the client into PATH
    mullvad-vpn

    # Keyboard config
    (callPackage ../pkgs/obinskit-fixed { })
  ];

  # Needed by obinskit
  nixpkgs.config.permittedInsecurePackages = [
    "electron-13.6.9"
  ];

  # Enable zsh properly
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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
  hardware.sane.brscan4.enable = true;
  hardware.sane.brscan4.netDevices = {
    e514dw = {
      ip = "192.168.0.105";
      model = "MFC-L2700DW"; # Dunno why this model, but it works
    };
  };

  services.pipewire.enable = true;
  xdg.portal = {
    enable = true;
    #extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  };

  # Enable KDE
  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  # So themes are applied to GTK apps
  programs.dconf.enable = true;

  # Enable flatpak support
  services.flatpak.enable = true;

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
