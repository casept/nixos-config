{ pkgs, ... }: {
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
  home.stateVersion = "24.05";

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.mozilla.firefox.desktop";
    "x-scheme-handler/http" = "org.mozilla.firefox.desktop";
    "x-scheme-handler/https" = "org.mozilla.firefox.desktop";
    "x-scheme-handler/about" = "org.mozilla.firefox.desktop";
    "x-scheme-handler/unknown" = "org.mozilla.firefox.desktop";

    "application/x-bittorrent" = "com.transmissionbt.Transmission.desktop";
    "x-scheme-handler/magnet" = "com.transmissionbt.Transmission.desktop";

    "application/vnd.apple.mpegurl" = "vlc.desktop";
    "application/x-mpegurl" = "vlc.desktop";
    "video/3gpp" = "org.videolan.VLC.desktop";
    "video/mp4" = "org.videolan.VLC.desktop";
    "video/mpeg" = "org.videolan.VLC.desktop";
    "video/ogg" = "org.videolan.VLC.desktop";
    "video/quicktime" = "org.videolan.VLC.desktop";
    "video/webm" = "org.videolan.VLC.desktop";
    "video/x-m4v" = "org.videolan.VLC.desktop";
    "video/ms-asf" = "org.videolan.VLC.desktop";
    "video/x-ms-wmv" = "org.videolan.VLC.desktop";
    "video/x-msvideo" = "org.videolan.VLC.desktop";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode.fhs;
  };

  # Enable native Wayland support
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
    # Editors
    unstable.helix
    unstable.zed-editor
    (pkgs.writeShellScriptBin "z" "exec -a $0 ${unstable.zed-editor}/bin/zeditor $@")

    # Linters and formatters (global for convenience)
    shellcheck
    nixpkgs-fmt
    unstable.nixd
    # Misc. tools
    cloudflared
    starship
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
    monitorets
    imv

    # Reverse engineering
    unstable.ghidra
    python311Packages.binwalk-full

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
    simple-scan
    texlive.combined.scheme-full

    # Diagnostics
    nmap
    inetutils
    ethtool
    usbutils

    # Media
    unstable.noisetorch
    unstable.droidcam
    unstable.obs-studio
    unstable.obs-studio-plugins.wlrobs

    # Misc
    vagrant
    tio
  ];
}
