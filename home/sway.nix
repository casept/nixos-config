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
    unstable.squeekboard
    unstable.albert
    ffmpeg-full
    libnotify
    blueberry
    gnome3.networkmanagerapplet
    gnome3.gnome-keyring
    kanshi
    autotiling
    xdg_utils
    xdg-user-dirs
    polkit_gnome

    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin

    # Fonts
    dejavu_fonts
    # nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    liberation_ttf
    source-code-pro
    roboto
  ];

  # GTK stuff
  gtk.enable = true;
  gtk.font.package = pkgs.dejavu_fonts;
  gtk.font.name = "DejaVu Sans";
  gtk.iconTheme.package = pkgs.paper-icon-theme;
  gtk.iconTheme.name = "Paper";
  gtk.theme.package = pkgs.unstable.gruvbox-dark-gtk;
  gtk.theme.name = "gruvbox-dark";

  home.keyboard.layout = "eu";

  systemd.user.services.gammastep = {
    Unit.Description = "Gammastep service";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = { ExecStart = "${pkgs.gammastep}/bin/gammastep"; };
  };
}
