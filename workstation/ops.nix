{ config, pkgs, ... }: {
  # Set up virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [ distrobox gnome-boxes ];

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
  # services.geoipupdate.enable = true;
}
