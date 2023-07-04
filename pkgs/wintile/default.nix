{ stdenv, lib, fetchFromGitHub, glib, gnome3 }:
let uuid = "wintile@nowsci.com";
in stdenv.mkDerivation {
  pname = "gnome-shell-extension-wintile";
  version = "v2023.07.03-1";

  src = fetchFromGitHub {
    owner = "Fmstrat";
    repo = "wintile";
    rev = "3e43c62dd5f25aa32e28a65f2c4777b03b6ca3ee";
    sha256 = "sha256-hD1muHnC+5oFOFwm8IVC9WHyzfdCDj5O35kK3mXUgak=";
  };

  nativeBuildInputs = [ glib ];
  buildPhase = ''
    runHook preBuild
    glib-compile-schemas .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r * $out/share/gnome-shell/extensions/${uuid}/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Windows 10 window tiling for GNOME";
    license = licenses.gpl3;
    homepage = "https://github.com/Fmstrat/wintile";
    platforms = gnome3.gnome-shell.meta.platforms;
  };
}
