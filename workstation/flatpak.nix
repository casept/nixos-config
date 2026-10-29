{ config, lib, pkgs, ... }:
let
  # Reuse the allocator NixOS preloads into host binaries, but strip its
  # RUNPATH: inside a Flatpak sandbox it must bind to the runtime's
  # libc/libstdc++ rather than pulling NixOS's copies in via /nix/store.
  nativeMalloc =
    lib.removeSuffix "\n" (config.environment.etc."ld-nix.so.preload".text or "");
  mallocName =
    if nativeMalloc == "" then "libhardened_malloc.so" else baseNameOf nativeMalloc;
  hmallocFlatpak = pkgs.runCommand "libhardened_malloc-flatpak" { } ''
    mkdir -p $out/lib
    cp -L ${nativeMalloc} $out/lib/${mallocName}
    chmod u+w $out/lib/${mallocName}
    ${pkgs.patchelf}/bin/patchelf --remove-rpath $out/lib/${mallocName}
  '';
in
{
  # Enable flatpak support
  services.flatpak.enable = true;

  # Preload the host's hardened_malloc into Flatpaks, mirroring secureblue's
  # `ujust harden-flatpak`. Flatpaks use their own runtime glibc and therefore
  # do not honour /etc/ld-nix.so.preload.
  services.flatpak.overrides = lib.mkIf
    (config.environment.memoryAllocator.provider != "libc")
    {
      settings.global = {
        Context.filesystems = [ "${hmallocFlatpak}:ro" ];
        Environment = {
          LD_PRELOAD = "${hmallocFlatpak}/lib/${mallocName}";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
        };
      };

      # These don't like hardened_malloc
      settings."org.mozilla.firefox".Context."unset-environment" = [ "LD_PRELOAD" ];
      settings."org.mozilla.thunderbird".Context."unset-environment" = [ "LD_PRELOAD" ];
      settings."org.torproject.torbrowser-launcher".Context."unset-environment" = [ "LD_PRELOAD" ];
    };

  services.flatpak.packages = [
    "com.calibre_ebook.calibre"
    "com.getpostman.Postman"
    "com.github.jeromerobert.pdfarranger"
    "com.github.rajsolai.textsnatcher"
    "com.github.skylot.jadx"
    "com.github.tchx84.Flatseal"
    "com.github.zocker_160.SyncThingy"
    "com.github.xournalpp.xournalpp"
    "com.google.Chrome"
    "com.ktechpit.whatsie"
    "com.oppzippy.OpenSCQ30"
    "com.prusa3d.PrusaSlicer"
    "com.slack.Slack"
    "com.valvesoftware.Steam"
    "de.bund.ausweisapp.ausweisapp2"
    "im.riot.Riot"
    "io.dbeaver.DBeaverCommunity"
    "io.github.TransmissionRemoteGtk"
    "net.pcsx2.PCSX2"
    "net.werwolv.ImHex"
    "org.bleachbit.BleachBit"
    "org.filezillaproject.Filezilla"
    "org.inkscape.Inkscape"
    "org.jdownloader.JDownloader"
    "org.kde.filelight"
    "org.kde.itinerary"
    "org.kde.okteta"
    "org.keepassxc.KeePassXC"
    "org.libreoffice.LibreOffice"
    "org.mozilla.thunderbird"
    "org.mozilla.firefox"
    "org.openscad.OpenSCAD"
    "org.pulseaudio.pavucontrol"
    "org.remmina.Remmina"
    "org.signal.Signal"
    "org.speedcrunch.SpeedCrunch"
    "org.telegram.desktop"
    "org.torproject.torbrowser-launcher"
    "org.videolan.VLC"
    "org.zealdocs.Zeal"
  ];

  # So fonts show up in Flatpak apps
  fonts.fontDir.enable = true;
}
