{ pkgs, ... }: {
  home.packages = with pkgs; [
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
    wf-recorder
    wofi
    ffmpeg-full
    libnotify
    blueberry
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
  ];

  systemd.user.services.gammastep = {
    Unit.Description = "Gammastep service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = { ExecStart = "${pkgs.gammastep}/bin/gammastep"; };
  };

  home.sessionVariables = {
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
}
