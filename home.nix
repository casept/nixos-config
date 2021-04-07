{ pkgs, nixos-vsliveshare, ... }: {
  #nixpkgs.config.allowUnfree = true;
  #nixpkgs.overlays = [ overlay-unstable ];

  #imports =
  #  [ ./home/gnome.nix ./home/sway.nix ./home/vscode.nix ./home/neovim.nix ];
  imports = [ ./home/sway.nix ./home/vscode.nix ./home/neovim.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "user";
  home.homeDirectory = "/home/user";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  services.lorri.enable = true;
  services.syncthing.enable = true;
  services.syncthing.tray = true;

  # Legacy tools expect a channel
  #home.sessionVariables = {
  #  NIX_PATH = builtins.concatStringsSep ":" [
  #    "nixpkgs=${pkgs}"
  #    "nixos-config=/etc/nixos/configuration.nix"
  #    "/nix/var/nix/profiles/per-user/root/channels"
  #  ];
  #};

  home.packages = with pkgs; [
    # Browsers
    unstable.firefox
    unstable.chromium
    filezilla

    # Editors
    kakoune
    kak-lsp
    unstable.jetbrains.idea-ultimate

    # Linters and formatters
    shellcheck
    nixfmt

    # Misc. Unix-ish tools
    direnv
    ripgrep
    ripgrep-all
    fzf
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

    # Reverse engineering
    unstable.ghidra-bin
    jd-gui
    unstable.python38Packages.binwalk-full

    # Nix-specific tools
    appimage-run
    nix-index
    patchelf
    unstable.cachix
    unstable.nix-tree
    #comma

    # Games
    multimc
    wine
    (lowPrio wineWowPackages.full)
    steam-run-native

    # Note-taking
    xournalpp
    simple-scan
    texlive.combined.scheme-full
    evince

    # Network diagnostics
    nmap
    inetutils

    # Media
    rhythmbox
    unstable.noisetorch

    # Office
    libreoffice-fresh

    # Misc
    vagrant
  ];
}
