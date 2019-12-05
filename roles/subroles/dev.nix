{ config, pkgs, ... }:

  # Enable support for installing from unstable without having to add it using nix-channel first
  let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  in
  {
    nixpkgs.config = {
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
    };
  

  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Development packages
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim
    unstable.vscode
    unstable.android-studio

    # Reversing
    unstable.ghidra-bin
    unstable.python37Packages.binwalk-full

    # Misc. CLI tools
    shellcheck
    ripgrep
    htop
    stow
    tmux
    unstable.alacritty
    wget
    curl
    unar
    unzip
    binutils

    # Source control    
    git

    # Languages
    python3
    unstable.dotnet-sdk
    unstable.rustup
    unstable.go
    openjdk8

    # Build environment management
    unstable.vagrant
    direnv
    flatpak-builder

  ];

  services.lorri.enable = true;
  
  programs.adb.enable = true;
 
}
