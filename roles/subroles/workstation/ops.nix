{ config, pkgs, ... }: {
  # Set up virtualisation
  virtualisation.lxd.enable = true;

  virtualisation.virtualbox = {
    host.enable = true;
    host.package = pkgs.unstable.virtualbox;
    host.enableExtensionPack = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Creating images for funky architectures
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "mips64-linux"
    "mips64el-linux"
    "mips-linux"
    "mipsel-linux"
  ];

  # Debugging the network
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;
  # services.geoipupdate.enable = true;
}
