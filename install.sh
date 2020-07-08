#! /usr/bin/env nix-shell
#! nix-shell -i bash -p python3 stow git bash
# shellcheck shell=bash
set -eu pipefail
# This script is designed for manual setup, and is therefore interactive.
# It's idempotent.

echo "Have you set the hardware-configuration-current.nix, role-current.nix and box-current.nix symlinks correctly? [y/N]"
read -r symlinked
if [ "$symlinked" = "y" ]; then
    echo "Continuing..."
else
    echo "Please set the symlinks first"
    exit 1
fi

echo "Adding system channels"
sudo nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update

echo "Rebuilding system config"
sudo nixos-rebuild switch

# The steps below only make sense if user is not root
if [ "$EUID" -ne 0 ]; then
    echo "Adding user channels"
    nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
    nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
    nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
    nix-channel --update

    echo "Install home-manager and dotfiles? [y/N]"
    read -r INSTALL_HOME
    if [ "$INSTALL_HOME" = "y" ]; then
        echo "Cloning dotfiles..."
        git clone --recursive https://github.com/casept/dotfiles/ ~/dotfiles
        cd ~/dotfiles || exit 1
        python3 ./install.py
        cd "$OLDPWD"
        echo "Linking home-manger config..."
        ln -s ./home.nix /home/user/.config/nixpkgs/home.nix
        echo "Rebuilding home-manager config..."
        home-manager switch
    fi
fi