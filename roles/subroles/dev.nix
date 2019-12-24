{ config, pkgs, ... }:
{  

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Development packages
  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    python37Packages.pynvim # For deoplete
    vimHugeX

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
    unar
    unzip
    binutils

    # Source control    
    git

    # Languages
    python3
    python37Packages.autopep8
    python37Packages.flake8
    python37Packages.pydocstyle
    python37Packages.mypy

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
