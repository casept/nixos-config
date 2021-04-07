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
    wpa_supplicant
    wpa_supplicant_gui
    xfce.gvfs
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin

    # Fonts
    dejavu_fonts
    # nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
  ];

  # GTK stuff
  #fonts.fontconfig.enable = true;
  gtk.enable = true;
  gtk.font.package = pkgs.dejavu_fonts;
  gtk.font.name = "DejaVu Sans";
  gtk.iconTheme.package = pkgs.paper-icon-theme;
  gtk.iconTheme.name = "Paper";

  home.keyboard.layout = "eu";

  systemd.user.services.gammastep = {
    Unit.Description = "Gammastep service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = { ExecStart = "${pkgs.gammastep}/bin/gammastep"; };
  };
}
