{ pkgs, nixos-vsliveshare, ... }:

{
  # Enable vscode
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode.fhs;
  };

  # Enable native Wayland support
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
