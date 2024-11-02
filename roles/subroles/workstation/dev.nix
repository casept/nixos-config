{ config, environment, pkgs, ... }: {
  programs.adb.enable = true;

  # Udev rules for programming a RISC-V dev board from china
  services.udev.extraRules =
    "ATTRS{idVendor}''=''\"28e9''\", ATTRS{idProduct}''=''\"0189''\", MODE=''\"0666''\", ENV{ID_MM_DEVICE_IGNORE}''=''\"1''\", ENV{IF_MM_PORT_IGNORE}''=''\"1''\"";


  environment.systemPackages = with pkgs; [
    # Common programming tools I always want available
    # C/C++
    unstable.gcc
    unstable.clang
    unstable.clang-tools
    unstable.ccacheWrapper
    unstable.ccache
    # Go
    unstable.go
    unstable.gopls
    unstable.delve
    unstable.gomodifytags
    unstable.gotests
    unstable.impl
    # Rust
    unstable.cargo
    unstable.cargo-geiger
    unstable.cargo-fuzz
    # Python
    python3
  ];
}
