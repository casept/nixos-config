let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in { config, pkgs, ... }:

{
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
}
