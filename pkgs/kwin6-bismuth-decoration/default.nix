{ stdenv, lib, fetchFromGitHub, cmake, kdePackages, pkg-config }:
stdenv.mkDerivation {
  pname = "kwin6-bismuth-decoration";
  version = "master";

  src = fetchFromGitHub {
    owner = "ivan-cukic";
    repo = "kwin6-bismuth-decoration";
    rev = "ab6755fa1ca8d61535ff41e6a60d82b680847008";
    sha256 = "sha256-AXIyBRAW16pPVxWbhRcecCi9Lf3MsQMakSZD+a+BtSU=";
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
