# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let unstable = import <nixos-unstable> { };

in { config, pkgs, builtins, ... }: {

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  imports = [
    ./subroles/workstation/dev.nix
    ./subroles/workstation/ops.nix
    ./subroles/workstation/mullvad.nix
  ];

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Misc. uncategorized packages
  environment.systemPackages = with pkgs; [
    openconnect
    bleachbit
    # Desktop backup
    unstable.pkgs.rclone
    # Stable does not support new bitlocker versions
    (callPackage ../pkgs/dislocker-master { })
    unstable.pkgs.restic
    virt-manager
    # Required for proper QT sway support
    qt5.qtwayland
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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.gutenprintBin
    pkgs.hplipWithPlugin
    pkgs.samsungUnifiedLinuxDriver
    pkgs.splix
    pkgs.brlaser
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
    pkgs.cups-dymo
    pkgs.mfcl2700dncupswrapper
    pkgs.mfcl2700dnlpr
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
  xdg.portal.extraPortals = [ unstable.pkgs.xdg-desktop-portal-wlr ];
  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" "adbusers" "lp" "scanner" ];
  };

  # I'm the only user and desktop Linux security is a mess, so this isn't really a problem
  nix.trustedUsers = [ "root" "user" ];

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;
}
