{ pkgs, nixos-vsliveshare, ... }: {
  imports = [ ./home/vscode.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "casept";
  home.homeDirectory = "/home/casept";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  services.lorri.enable = true;
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.gnome.Evince.desktop" ];

    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";

    "application/x-bittorrent" = "com.transmissionbt.Transmission.desktop";
    "x-scheme-handler/magnet" = "com.transmissionbt.Transmission.desktop";

    "application/vnd.apple.mpegurl" = "vlc.desktop";
    "application/x-mpegurl" = "vlc.desktop";
    "video/3gpp" = "vlc.desktop";
    "video/mp4" = "vlc.desktop";
    "video/mpeg" = "vlc.desktop";
    "video/ogg" = "vlc.desktop";
    "video/quicktime" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/x-m4v" = "vlc.desktop";
    "video/ms-asf" = "vlc.desktop";
    "video/x-ms-wmv" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";
  };

  home.packages = with pkgs; [
    # Browsers
    unstable.firefox
    unstable.chromium
    unstable.thunderbird
    filezilla

    # Editors
    helix

    # Linters and formatters (global for convenience)
    shellcheck
    nixfmt-classic
    # Misc. Unix-ish tools
    direnv
    ripgrep
    ripgrep-all
    fzf
    filet
    gnupg
    htop
    stow
    tmux
    tmate
    alacritty
    wget
    curl
    unar
    unzip
    binutils
    file
    killall
    xorg.xkill
    git
    sshfs
    pv
    psensor
    zeal
    imv

    # Reverse engineering
    unstable.ghidra-bin
    jd-gui
    python311Packages.binwalk-full
    avalonia-ilspy

    # Nix-specific tools
    (appimage-run.override { extraPkgs = pkgs: [ pkgs.xorg.libxshmfence ]; })
    nix-index
    patchelf
    cachix
    nix-tree
    #comma

    # Games
    prismlauncher
    (pkgs.callPackage ./pkgs/technic-launcher { })
    wine
    (lowPrio wineWowPackages.full)
    steam-run-native
    unstable.lutris

    # Note-taking
    xournalpp
    simple-scan
    texlive.combined.scheme-full
    evince
    inkscape

    # Network diagnostics
    nmap
    inetutils

    # Media
    vlc
    rhythmbox
    unstable.noisetorch
    unstable.droidcam
    unstable.obs-studio
    unstable.obs-studio-plugins.wlrobs

    # Office
    libreoffice-fresh

    # Security
    keepassxc

    # Misc
    vagrant
  ];
}
