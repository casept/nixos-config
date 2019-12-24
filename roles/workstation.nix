# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, builtins, ... }:
{
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub.efiInstallAsRemovable = false;
  
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = true;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  networking.interfaces.wwp0s20u4i6.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
 
  imports =
    [ 
      ./subroles/dev.nix
      ./subroles/ops.nix
      ./subroles/sec.nix
      ./subroles/touch.nix
      ./subroles/internet.nix
      ./subroles/entertainment.nix
    ];

  # Misc. uncategorized packages
  environment.systemPackages = with pkgs; [
    keepassxc
    appimage-run
    texlive.combined.scheme-full
    bleachbit
    speedcrunch
    deja-dup
    gnucash
    gnomeExtensions.gsconnect
  ];


  # Set up virtualisation
  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # Enable zsh properly
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin pkgs.hplipWithPlugin pkgs.samsungUnifiedLinuxDriver pkgs.splix pkgs.brlaser ];

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
    extraGroups = [ "wheel" "docker" "vboxusers" "plugdev" "adbusers"];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
