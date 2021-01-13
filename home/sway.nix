{ pkgs, ... }: {
  home.packages = with pkgs; [
    bemenu
    brightnessctl
    gammastep
    grim
    i3status
    j4-dmenu-desktop
    jq
    libappindicator
    mako
    pavucontrol
    playerctl
    slurp
    swaybg
    waybar
    wdisplays
    xwayland
  ];

  systemd.user.services.gammastep = {
    Unit.Description = "Gammastep service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = { ExecStart = "${pkgs.gammastep}/bin/gammastep"; };
  };

  home.sessionVariables = {
    BEMENU_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
}
