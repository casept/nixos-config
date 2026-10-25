{ environment, pkgs, services, ... }: {
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # Don't use these
    elisa
    # For some reason env activation after rebuild gets blocked until index completes
    baloo
  ];

  programs.kdeconnect.enable = true;

  environment.systemPackages = [
    # Latest git master, includes fixes not yet in a tagged release
    (pkgs.unstable.callPackage ../pkgs/krohnkite { })
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.discover
    pkgs.kdePackages.partitionmanager
    pkgs.kdePackages.kconfig
    (pkgs.callPackage ../pkgs/kwin6-bismuth-decoration { })
    # Most distros call this qdbus6, create symlink so I can keep scripts portable
    (pkgs.writeShellScriptBin "qdbus6" "exec -a $0 ${pkgs.kdePackages.qttools}/bin/qdbus $@")
    (pkgs.writeShellScriptBin "qdbus-qt6" "exec -a $0 ${pkgs.kdePackages.qttools}/bin/qdbus $@")
  ];

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-x11";
}
