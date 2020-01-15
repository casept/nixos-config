{ config, pkgs, ... }:
{  

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Development packages
  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    python38Packages.pynvim # For deoplete
    
    vscode
    android-studio

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
 
}
