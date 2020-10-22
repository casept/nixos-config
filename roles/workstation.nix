{ pkgs, hardware, home-manager, comma, nixos-vsliveshare, nixpkgs
, nixpkgs-unstable, ... }: {
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;

  time.timeZone = "Europe/Berlin";

  imports = [
    ./subroles/workstation/dev.nix
    ./subroles/workstation/ops.nix
    ../services/mullvad.nix
  ];

  systemd.services.mullvad-daemon.enable = true;

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Misc. uncategorized packages
  environment.systemPackages = with pkgs; [
    openconnect
    bleachbit
    # Desktop backup
    pkgs.unstable.rclone
    # Stable does not support new bitlocker versions
    (callPackage ../pkgs/dislocker-master { })
    pkgs.unstable.restic
    virt-manager
    # Required for proper QT sway support
    qt5.qtwayland
    # The service doesn't put the client into PATH
    pkgs.unstable.mullvad-vpn
  ];

  # Enable zsh properly
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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
    samsungUnifiedLinuxDriver
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

  # GNOME config
  services.xserver = {
    enable = true;
    layout = "eu";
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };
    desktopManager.gnome3.enable = true;
  };
  services.dbus.packages = [ pkgs.gnome3.dconf ];
  services.udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

  # Sway config
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
  # TODO: Pull from stable once 20.09 is released
  xdg.portal.extraPortals = [ pkgs.unstable.xdg-desktop-portal-wlr ];

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.users.user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups =
      [ "wheel" "docker" "plugdev" "adbusers" "lp" "scanner" "vboxusers" ];
  };
  # FIXME: Call home-manager from here so it's guaranteed to have the same flake versions as system
  #home-manager.users.user = (import ../home.nix {
  #  inherit nixpkgs nixpkgs-unstable comma nixos-vsliveshare;
  #});

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.trustedUsers = [ "root" "user" ];

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;
}
