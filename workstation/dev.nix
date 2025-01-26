{ config, environment, pkgs, ... }: {
  programs.adb.enable = true;

  # DJI and FTDI devices
  services.udev.extraRules = ''
    ATTRS{idVendor}=="2ca3", MODE="0660", GROUP="wheel"
    ATTRS{idVendor}=="0403", MODE="0660", GROUP="wheel"
  '';

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
