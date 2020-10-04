{ pkgs, home, programs, ... }: {
  # Needed to enable pulseaudio support for waybar
  nixpkgs.config.pulseaudio = true;

  home.packages = [
    pkgs.libappindicator
    pkgs.waybar
    pkgs.swaybg
    pkgs.xwayland
    pkgs.grim
    pkgs.slurp
    pkgs.j4-dmenu-desktop
    pkgs.bemenu
    pkgs.i3status
    pkgs.mako
    pkgs.playerctl
    pkgs.pavucontrol
    pkgs.brightnessctl
    pkgs.jq
  ];

  home.sessionVariables = {
    BEMENU_BACKEND = "wayland";
    # Needed to have a functional waybar tray
    XDG_CURRENT_DESKTOP = "Unity";
  };
}
