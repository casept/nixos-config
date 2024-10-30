{ pkgs, hardware, home-manager, nixos-vsliveshare, systemd, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.PasswordAuthentication = false;

  time.timeZone = "Europe/Berlin";

  imports = [
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

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Enable talking to a U2F dongle
  services.udev.extraRules =
    "ATTRS{idVendor}''=''\"2ccf''\", ATTRS{idProduct}''=''\"0854''\", MODE=''\"0660''\"";

  # Misc. uncategorized packages


  environment.systemPackages = with pkgs; [
    openconnect
    bleachbit
    # Desktop backup
    rclone
    # Stable does not support new bitlocker versions
    (callPackage ../pkgs/dislocker-master { })
    unstable.rustic
    mosh
    sshuttle
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
  services.flatpak.packages = [
    "com.calibre_ebook.calibre"
    "com.getpostman.Postman"
    "com.github.junrrein.PDFSlicer"
    "com.github.rajsolai.textsnatcher"
    "com.github.skylot.jadx"
    "com.github.tchx84.Flatseal"
    "com.github.zocker_160.SyncThingy"
    "com.github.xournalpp.xournalpp"
    "com.google.Chrome"
    "com.ktechpit.whatsie"
    "com.oppzippy.OpenSCQ30"
    "com.prusa3d.PrusaSlicer"
    "com.slack.Slack"
    "com.spotify.Client"
    "com.ulduzsoft.Birdtray"
    "com.valvesoftware.Steam"
    "de.bund.ausweisapp.ausweisapp2"
    "im.nheko.Nheko"
    "io.dbeaver.DBeaverCommunity"
    "io.github.TransmissionRemoteGtk"
    "net.pcsx2.PCSX2"
    "net.werwolv.ImHex"
    "org.bleachbit.BleachBit"
    "org.filezillaproject.Filezilla"
    "org.inkscape.Inkscape"
    "org.jdownloader.JDownloader"
    "org.kde.filelight"
    "org.kde.itinerary"
    "org.kde.okteta"
    "org.keepassxc.KeePassXC"
    "org.libreoffice.LibreOffice"
    "org.mozilla.Thunderbird"
    "org.mozilla.firefox"
    "org.openscad.OpenSCAD"
    "org.pulseaudio.pavucontrol"
    "org.remmina.Remmina"
    "org.signal.Signal"
    "org.speedcrunch.SpeedCrunch"
    "org.telegram.desktop"
    "org.torproject.torbrowser-launcher"
    "org.videolan.VLC"
    "org.zealdocs.Zeal"
  ];


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
  security.sudo.wheelNeedsPassword = false;

  # Way too annoying to manage on a desktop system IMHO
  networking.firewall.enable = false;
}
