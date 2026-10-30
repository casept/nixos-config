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

      # NixOS' Steam package already runs inside a bubblewrap FHS sandbox.
      # Instead of nesting a second bwrap around it, extend that sandbox.
      #
      # Games get a private, persistent $HOME.  Steam itself, its library and
      # the per-user VR state are bound back in below.  bwrap resolves bind
      # sources in the host namespace, so those source paths still refer to
      # the real home even after /home has been replaced by a tmpfs.
      extraPreBwrapCmds = ''
        # Start Steam in the sandboxed home, so it works from any CWD
        if [ "''${0##*/}" = "steam" ]; then
          cd "$HOME"
        fi

        REAL_HOME="$HOME"
        SANDBOX_HOME="$REAL_HOME/.local/share/steam-sandbox/home"
        mkdir -p "$SANDBOX_HOME"/{.cache,.config,.local/share,.steam}
        mkdir -p "$SANDBOX_HOME/.local/share/Steam"

        # Give the sandbox the user runtime directory, but hide the parts that
        # would let a game escape it (user systemd manager, podman, document
        # portal, key/ssh agents, flatpak state, ...).
        runtime_args=()
        if [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
          runtime_args+=(--bind "$XDG_RUNTIME_DIR" "$XDG_RUNTIME_DIR")
          for entry in doc gnupg ssh-agent systemd podman containers libpod .flatpak .flatpak-helper .flatpak-cache .dbus-proxy varlink app at-spi kwallet5.socket drkonqi-coredump-launcher; do
            if [ -e "$XDG_RUNTIME_DIR/$entry" ]; then
              if [ -d "$XDG_RUNTIME_DIR/$entry" ] && [ ! -L "$XDG_RUNTIME_DIR/$entry" ]; then
                runtime_args+=(--tmpfs "$XDG_RUNTIME_DIR/$entry")
              elif [ ! -L "$XDG_RUNTIME_DIR/$entry" ]; then
                runtime_args+=(--ro-bind /dev/null "$XDG_RUNTIME_DIR/$entry")
              fi
            fi
          done
        fi
      '';

      extraBwrapArgs = [
        ''--tmpfs /home''
        ''--bind "$SANDBOX_HOME" "$HOME"''

        # Steam itself, its libraries, Proton prefixes and VR state
        ''--bind-try "$REAL_HOME/.local/share/Steam" "$HOME/.local/share/Steam"''
        ''--bind-try "$REAL_HOME/.steam" "$HOME/.steam"''
        ''--bind-try "$REAL_HOME/.cache/SteamVR" "$HOME/.cache/SteamVR"''
        ''--bind-try "$REAL_HOME/.config/openvr" "$HOME/.config/openvr"''
        ''--bind-try "$REAL_HOME/steamvr" "$HOME/steamvr"''

        # OpenXR runtime selection (Monado/WiVRn) and the PulseAudio cookie
        ''--ro-bind-try "$REAL_HOME/.config/openxr" "$HOME/.config/openxr"''
        ''--ro-bind-try "$REAL_HOME/.local/share/openxr" "$HOME/.local/share/openxr"''
        ''--ro-bind-try "$REAL_HOME/.config/pulse" "$HOME/.config/pulse"''
        ''--ro-bind-try "$REAL_HOME/.pulse-cookie" "$HOME/.pulse-cookie"''

        # Per-user configuration that games commonly expect to be readable
        ''--ro-bind-try "$REAL_HOME/.config/MangoHud" "$HOME/.config/MangoHud"''
        ''--ro-bind-try "$REAL_HOME/.config/gamemode.ini" "$HOME/.config/gamemode.ini"''

        # Only expose what's needed for graphics, input, audio, X11/Wayland, D-Bus and VR
        ''--tmpfs /run''
        ''"''${runtime_args[@]}"''
        ''--ro-bind-try /run/udev /run/udev''
        ''--ro-bind /run/current-system /run/current-system''
        ''--ro-bind-try /run/opengl-driver /run/opengl-driver''
        ''--ro-bind-try /run/opengl-driver-32 /run/opengl-driver-32''
        ''--ro-bind-try /run/systemd/resolve /run/systemd/resolve''
        ''--ro-bind-try /run/NetworkManager/resolv.conf /run/NetworkManager/resolv.conf''

        # The FHS rootfs has its own /etc/xdg, which hides the host's OpenXR
        # runtime selection created by services.monado.defaultRuntime
        ''--ro-bind-try /etc/xdg /etc/xdg''

        # Hide host directories that the FHS wrapper would otherwise auto-bind
        ''--tmpfs /var''
        ''--dir /var/tmp''
        ''--symlink /run /var/run''
        ''--tmpfs /opt''
        ''--tmpfs /root''
        ''--tmpfs /boot''
        ''--tmpfs /srv''
        ''--tmpfs /mnt''
        ''--tmpfs /media''

        # Do not expose unrelated, potentially sensitive host configuration
        ''--tmpfs /.host-etc/nixos''
        ''--tmpfs /.host-etc/ssh''
        ''--tmpfs /.host-etc/NetworkManager/system-connections''
        ''--tmpfs /.host-etc/mullvad-vpn''

        ''--remount-ro /nix''
        ''--remount-ro /sys''
        ''--unshare-pid''
      ];
    };
  };
}
