# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, builtins, ... }: {

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.passwordAuthentication = false;

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  imports = [ ./subroles/workstation/dev.nix ./subroles/workstation/ops.nix ];

  # Needed for steam and many games.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Misc. uncategorized packages
  environment.systemPackages = with pkgs; [
    mullvad-vpn

    appimage-run
    #texlive.combined.scheme-full
    bleachbit
    #gnomeExtensions.gsconnect
    # Desktop backup
    (import ../pkgs/rclone-master.nix) # Stable does not support jottacloud well
    (import
      ../pkgs/dislocker-master.nix) # Stable does not support new bitlocker versions
    restic
  ];

  # Set up virtualisation
  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.libvirtd.enable = true;

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
  # services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin pkgs.hplipWithPlugin pkgs.samsungUnifiedLinuxDriver pkgs.splix pkgs.brlaser ];
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.gutenprintBin
    pkgs.samsungUnifiedLinuxDriver
    pkgs.splix
    pkgs.brlaser
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "eu";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager = {
    gdm.enable = true;
    gdm.wayland = true;
  };
  services.xserver.desktopManager.gnome3.enable = true;

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" "adbusers" ];
  };
}
