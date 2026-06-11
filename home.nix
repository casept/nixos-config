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
    xkill
    git
    git-lfs
    sshfs
    pv
    monitorets
    imv

    # Reverse engineering
    # Ghidra wrapped so that the `ghidra` command launches via PyGhidra,
    # giving Python 3 scripting support (the default launcher only ships
    # Jython/Python 2, which newer Ghidra releases no longer provide).
    #
    # We bypass Ghidra's pyghidraRun launcher because it insists on
    # creating/managing its own venv under ~/.config/ghidra (the Nix
    # python is "externally managed"), which ignores the pyghidra we
    # provide. Instead we invoke `python -m pyghidra` directly with a
    # pyghidra-enabled interpreter and a JDK, exactly as the launcher
    # would after its venv dance.
    (
      let
        pyghidraEnv = unstable.python3.withPackages (ps: [ ps.pyghidra ]);
      in
      unstable.symlinkJoin {
        name = "ghidra-pyghidra";
        paths = [ unstable.ghidra ];
        nativeBuildInputs = [ unstable.makeWrapper ];
        postBuild = ''
          rm -f $out/bin/ghidra
          makeWrapper ${pyghidraEnv}/bin/python3 $out/bin/ghidra \
            --add-flags "-m pyghidra -g --install-dir ${unstable.ghidra}/lib/ghidra" \
            --set JAVA_HOME ${unstable.openjdk21} \
            --prefix PATH : ${unstable.openjdk21}/bin \
            --set GHIDRA_INSTALL_DIR ${unstable.ghidra}/lib/ghidra
        '';
      }
    )
    unstable.binwalk

    # Nix-specific tools
    (appimage-run.override { extraPkgs = pkgs: [ pkgs.libxshmfence ]; })
    nix-index
    patchelf
    cachix
    nix-tree
    #comma

    # Games
    prismlauncher
    wine
    (lib.lowPrio wineWow64Packages.full)
    steam-run

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
    wl-clipboard
  ];
}
