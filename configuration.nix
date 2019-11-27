# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

  # Enable support for installing from unstable without having to add it using nix-channel first
  let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  in
  {
    nixpkgs.config = {
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
    };
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos-hardware/lenovo/thinkpad/x230>
    ];

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
  
  # Configure encrypted boot device.
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/8ff732bc-94fe-42ec-883c-b0e7e960e5fc";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "nixos"; # Define your hostname.
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


  # List packages installed in system profile.
  # Development environment
  #devpkgs = with pkgs; [
  #  vim neovim git vscode python3
  #]

  # Sysadmin utilities
  #sysadmpkgs = with pkgs; [
  #  htop stow tmux alacritty wget curl
  #]

  # Internet
  #netpkgs = with pkgs; [
  #  google-chrome firefox deluge
  #]

  # Gaming
  #gamepkgs = with pkgs; [
  #  steam
  #]

  # Note taking
  #noteepkgs = with pkgs; [
  #  xournalpp
  #]
  
  environment.systemPackages = with pkgs; [
    keepassxc
    vim neovim git python3 ripgrep shellcheck openjdk8 unstable.dotnet-sdk unstable.rustup unstable.go unstable.android-studio appimage-run
    unstable.vscode # To always get the latest version
    htop stow tmux alacritty wget curl nixops
    unstable.google-chrome unstable.firefox deluge
    unstable.steam unstable.steam-run
    lutris
    #unstable.xournalpp # Toolbox is unstable-only
    unstable.krita
    texlive.combined.scheme-full
    unstable.mullvad-vpn
    unstable.thunderbird
    unstable.ghidra-bin
    vlc
    calibre
    bleachbit
    speedcrunch
    unar unzip
    unstable.syncthing-gtk
    deja-dup
    unstable.tdesktop
    unstable.discord
    unstable.signal-desktop
    multimc
    gnucash
    gnomeExtensions.gsconnect
    flatpak-builder
    (wine.override { wineBuild = "wineWow"; })
  ];

  # Set up virtualization
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin pkgs.hplipWithPlugin pkgs.samsungUnifiedLinuxDriver pkgs.splix pkgs.brlaser ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "eu";

  # TODO: Enable wayland

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Needed for steam.
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  
  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Enable TLP
  services.tlp.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "vboxusers" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

