# { nixpkgs, nixpkgs-unstable, comma, nixos-vsliveshare, ... }:
#let
#  system = "x86_64-linux";
#  overlay-unstable = final: prev: {
#    unstable = import nixpkgs-unstable {
#      inherit system;
#      config.allowUnfree = true;
#    };
#  };
#in {
{ pkgs, nixos-vsliveshare, ... }: {
  #nixpkgs.config.allowUnfree = true;
  #nixpkgs.overlays = [ overlay-unstable ];

  imports =
    [ ./home/gnome.nix ./home/sway.nix ./home/vscode.nix ./home/neovim.nix ];

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

  #home.packages = with nixpkgs.pkgs; [
  home.packages = with pkgs; [
    # Browsers
    unstable.firefox
    unstable.google-chrome
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
    fzf
    gnupg
    htop
    stow
    tmux
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
    unstable.wine
    (lowPrio unstable.wineWowPackages.full)
    steam-run-native
    unstable.lutris

    # Note-taking
    xournalpp
    simple-scan
    texlive.combined.scheme-full

    # Network diagnostics
    nmap
    inetutils

    # Media playback
    rhythmbox

    # Misc
    unstable.vagrant
  ];
}
