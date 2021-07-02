{ pkgs, hardware, home-manager, nixos-vsliveshare, rnix-lsp-flake, ... }: {
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;

  time.timeZone = "Europe/Berlin";

  imports = [
    ../builders.nix
    ./subroles/workstation/dev.nix
    ./subroles/workstation/ops.nix
  ];

  services.mullvad-vpn.enable = true;

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

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
    pkgs.unstable.rclone
    # Stable does not support new bitlocker versions
    (callPackage ../pkgs/dislocker-master { })
    pkgs.unstable.restic
    virt-manager
    # Required for proper QT sway support
    qt5.qtwayland
    # The service doesn't put the client into PATH
    mullvad-vpn
  ];

  # Mainline wireguard plus nice power savings
  boot.kernelPackages = pkgs.linuxPackages_5_10;

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

  # Sway config
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export XDG_CURRENT_DESKTOP=sway
      export MOZ_ENABLE_WAYLAND=1
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  services.pipewire.enable = true;
  xdg.portal.enable = true;
  xdg.portal.gtkUsePortal = true;
  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
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
  home-manager.users.user = ../home.nix;

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.trustedUsers = [ "root" "user" ];

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;

  # Need some of that v4l loopback as a workaround for apps dragging their feet on pipewire support
  boot.extraModulePackages = [ pkgs.linuxPackages_5_10.v4l2loopback ];
}
