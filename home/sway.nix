# TODO: Once upgraded to 20.09 gammastep is in stable
{ pkgs, home, programs, gammastep, ... }: {
  # Needed to enable pulseaudio support for waybar
  nixpkgs.config.pulseaudio = true;

  home.packages = [
    gammastep
    pkgs.bemenu
    pkgs.brightnessctl
    pkgs.grim
    pkgs.i3status
    pkgs.j4-dmenu-desktop
    pkgs.jq
    pkgs.libappindicator
    pkgs.mako
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.slurp
    pkgs.swaybg
    pkgs.waybar
    pkgs.wdisplays
    pkgs.xwayland
  ];

  systemd.user.services.gammastep = {
    Unit.Description = "Gammastep service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = { ExecStart = "${gammastep}/bin/gammastep"; };
  };

  home.sessionVariables = {
    BEMENU_BACKEND = "wayland";
    # Needed to have a functional waybar tray
    XDG_CURRENT_DESKTOP = "Unity";
  };
}
