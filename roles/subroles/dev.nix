{ config, pkgs, ... }:
{  

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Development packages
  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    python38Packages.pynvim # For deoplete

    kakoune
    kak-lsp

    vscode
    android-studio
    jetbrains.idea-ultimate

    # Misc. CLI tools
    shellcheck
    ripgrep
    htop
    stow
    tmux
    alacritty
    wget
    curl
    #unar
    unzip
    binutils

    # Source control    
    git

    # Languages
    python38
    python38Packages.autopep8
    python38Packages.flake8
    python38Packages.pydocstyle
    python38Packages.mypy

    dotnet-sdk
    rustup
    go
    openjdk8

    # Build environment management
    vagrant
    direnv
    flatpak-builder

  ];

  services.lorri.enable = true;
  
  programs.adb.enable = true;
services.udev.extraRules = "ATTRS{idVendor}''\=''\"28e9''\", ATTRS{idProduct}''\=''\"0189''\", MODE=''\"0666''\", ENV{ID_MM_DEVICE_IGNORE}''\=''\"1''\", ENV{IF_MM_PORT_IGNORE}''\=''\"1''\"";
 
}
