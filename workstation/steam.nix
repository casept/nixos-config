{ pkgs, ... }: {
  # Needed for Steam and many games
  hardware.graphics.enable32Bit = true;
  services.pipewire.alsa.support32Bit = true;

  # For Dualshock 3 support
  hardware.bluetooth.package = pkgs.bluez;
  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraProfile = ''
        # Allows Monado/WiVRn to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      '';
    };
  };
}
