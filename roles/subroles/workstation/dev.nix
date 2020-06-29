{ config, pkgs, ... }: {
  programs.adb.enable = true;
  # Udev rules for programming a RISC-V dev board from china
  services.udev.extraRules =
    "ATTRS{idVendor}''=''\"28e9''\", ATTRS{idProduct}''=''\"0189''\", MODE=''\"0666''\", ENV{ID_MM_DEVICE_IGNORE}''=''\"1''\", ENV{IF_MM_PORT_IGNORE}''=''\"1''\"";

}
