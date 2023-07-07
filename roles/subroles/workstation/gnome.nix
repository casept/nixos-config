{ config, pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;

  # Gnome pulls in pipewire, which breaks pulseaudio
  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
  ];

  # Needed by AppIndicators
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
