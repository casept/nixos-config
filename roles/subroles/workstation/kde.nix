{ environment, pkgs, services, ... }: {
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    # For some reason env activation after rebuild gets blocked until index completes
    baloo
    elisa
  ];

  environment.systemPackages = [
    # Version with Plasma 6 support not yet in stable nixos
    pkgs.unstable.kdePackages.krohnkite
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.discover
    (pkgs.callPackage ../../../pkgs/kwin6-bismuth-decoration { })
  ];
}
