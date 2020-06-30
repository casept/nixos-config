{ config, pkgs, ... }: {
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Sysadmin-related packages
  environment.systemPackages = with pkgs; [
    # Source control    
    git

    # Automation
    nixops
    ansible

    # Debugging
    wireshark-qt
  ];

  # Creating images for funky architectures
  boot.binfmt.emulatedSystems =
    [ "aarch64-linux" "armv6l-linux" "armv7l-linux" "mips64-linux" "mips64el-linux" "mips-linux" "mipsel-linux" ];
}
