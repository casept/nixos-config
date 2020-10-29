{ pkgs, nixos-vsliveshare, ... }:

{
  # Enable vscode
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
  };

  # VS live share is broken without this
  # TODO: Reenable, currently mysteriously fails to import properly
  #imports = [ "${nixos-vsliveshare}/modules/vsliveshare/home.nix" ];
  #services.vsliveshare = {
  #  enable = true;
  #  extensionsDir = "$HOME/.vscode/extensions";
  #  nixpkgs = pkgs;
  #};
}
