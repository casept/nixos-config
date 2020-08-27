{ stdenv, lib, fetchFromGitHub, glib, gnome3 }:
let uuid = "wintile@nowsci.com";
in stdenv.mkDerivation {
  pname = "gnome-shell-extension-wintile";
  version = "v5";

  src = fetchFromGitHub {
    owner = "Fmstrat";
    repo = "wintile";
    rev = "99d11df499ea1e155fbaf48c31d464fb8976d8c0";
    sha256 = "0haq4i01h4wf0w52ri6r16yja6ca1qinx3fcigxiz5gv7pj2wgsh";
  };

  patches = [ ./0001-Removed-reference-to-gsconnect-extension.patch ];
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

  meta = with stdenv.lib; {
    description = "Windows 10 window tiling for GNOME";
    license = licenses.gpl3;
    homepage = "https://github.com/Fmstrat/wintile";
    platforms = gnome3.gnome-shell.meta.platforms;
  };
}
