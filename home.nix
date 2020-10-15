let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  comma = import (builtins.fetchGit {
    name = "comma";
    url = "https://github.com/Shopify/comma";
    ref = "refs/heads/master";
    rev = "4a62ec17e20ce0e738a8e5126b4298a73903b468";
  });
in { config, pkgs, home, ... }:

{
  imports = [
    "/etc/nixos/home/gnome.nix"
    "/etc/nixos/home/sway.nix"
    "/etc/nixos/home/vscode.nix"
    "/etc/nixos/home/neovim.nix"
  ];

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

  home.packages = [
    # Browsers
    unstable.pkgs.firefox
    unstable.pkgs.google-chrome
    pkgs.filezilla

    # Editors
    pkgs.kakoune
    pkgs.kak-lsp
    unstable.pkgs.jetbrains.idea-ultimate

    # Linters and formatters
    pkgs.shellcheck
    pkgs.nixfmt

    # Misc. Unix-ish tools
    pkgs.direnv
    pkgs.ripgrep
    pkgs.fzf
    pkgs.gnupg
    pkgs.htop
    pkgs.stow
    pkgs.tmux
    pkgs.alacritty
    pkgs.wget
    pkgs.curl
    pkgs.unar
    pkgs.unzip
    pkgs.binutils
    pkgs.file
    pkgs.killall
    pkgs.xorg.xkill
    pkgs.git
    pkgs.sshfs
    pkgs.pv

    # Reverse engineering
    unstable.pkgs.ghidra-bin
    pkgs.jd-gui
    unstable.pkgs.python38Packages.binwalk-full

    # Nix-specific tools
    pkgs.appimage-run
    pkgs.nix-index
    pkgs.patchelf
    unstable.pkgs.cachix
    unstable.pkgs.nix-tree
    (pkgs.callPackage comma { })

    # Games
    pkgs.multimc
    unstable.pkgs.wine
    (pkgs.lowPrio unstable.pkgs.wineWowPackages.full)
    pkgs.steam-run-native
    unstable.pkgs.lutris

    # Note-taking
    pkgs.xournalpp
    pkgs.simple-scan
    pkgs.texlive.combined.scheme-full

    # Network diagnostics
    pkgs.nmap
    pkgs.inetutils

    # Media playback
    pkgs.rhythmbox

    # Misc
    unstable.pkgs.vagrant
  ];
}
