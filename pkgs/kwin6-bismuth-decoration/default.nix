{ stdenv, lib, fetchFromGitHub, cmake, kdePackages, pkg-config }:
stdenv.mkDerivation {
  pname = "kwin6-bismuth-decoration";
  version = "master";

  src = fetchFromGitHub {
    owner = "ivan-cukic";
    repo = "kwin6-bismuth-decoration";
    rev = "603f3cca4d9b1c383a352f6e570a2e56138ecedb";
    sha256 = "sha256-4M8LwnR7Cl/iN2PR+pX0vauOyyilbPEtzFxTxD2ouA8=";
  };

  nativeBuildInputs = [ cmake kdePackages.extra-cmake-modules pkg-config ];
  buildInputs = [ kdePackages.kcmutils kdePackages.kconfig kdePackages.kconfigwidgets kdePackages.kcoreaddons kdePackages.kdeclarative kdePackages.kdecoration kdePackages.kglobalaccel kdePackages.kcmutils kdePackages.ki18n kdePackages.qtbase kdePackages.qtdeclarative kdePackages.qtsvg ];
  dontWrapQtApps = true;

  meta = with lib; {
    description = "Bismuth window decoration";
    homepage = "https://github.com/ivan-cukic/kwin6-bismuth-decoration";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
