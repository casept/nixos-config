#!/usr/bin/env bash
echo "Adding system channels"
sudo nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update

echo "Adding user channels"
nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --update

echo "Linking home-manger config..."
ln -s ./home.nix /home/user/.config/nixpkgs/home.nix
echo "Rebuilding home-manager config..."
home-manager switch

echo "Rebuilding system config"
sudo nixos-rebuild switch
