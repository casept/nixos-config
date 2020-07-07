{ config, pkgs, ... }: {
  # Use the GRUB 2 boot loader, because systemd doesn't support legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.grub.configurationLimit = 50;
  boot.loader.efi.canTouchEfiVariables = true;

  # It's a laptop
  services.logind.lidSwitch = "ignore";
}
