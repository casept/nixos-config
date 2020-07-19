let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in { config, pkgs, ... }:

{
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

  # Enable lorri
  services.lorri.enable = true;

  # Enable vscode
  programs.vscode = {
    enable = true;
    package = unstable.vscode;
  };

  # VS live share is broken without this
  imports = [
    "${
      fetchTarball "https://github.com/msteen/nixos-vsliveshare/tarball/master"
    }/modules/vsliveshare/home.nix"
  ];

  services.vsliveshare = {
    enable = true;
    extensionsDir = "$HOME/.vscode/extensions";
  };

  home.packages = [
    # Browsers
    unstable.pkgs.firefox
    unstable.pkgs.google-chrome

    # Editors
    pkgs.neovim
    pkgs.python38Packages.pynvim # For deoplete
    pkgs.kakoune
    pkgs.kak-lsp
    unstable.pkgs.jetbrains.idea-ultimate

    # Linters and formatters
    pkgs.shellcheck
    pkgs.nixfmt

    # Misc. Unix-ish tools
    pkgs.direnv
    pkgs.ripgrep
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
    pkgs.git

    # Reverse engineering
    unstable.pkgs.ghidra-bin
    pkgs.jd-gui
    unstable.pkgs.python38Packages.binwalk-full

    # Nix-specific tools
    pkgs.appimage-run

    # Games
    pkgs.multimc
    pkgs.wine
    pkgs.steam-run-native

    # Note-taking
    pkgs.xournalpp
    pkgs.simple-scan
    pkgs.texlive.combined.scheme-full
  ];
}
