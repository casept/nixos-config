{ stdenv, lib, fetchFromGitHub, cmake, kdePackages, pkg-config }:
stdenv.mkDerivation {
  pname = "kwin6-bismuth-decoration";
  version = "master";

  src = fetchFromGitHub {
    # Until https://github.com/ivan-cukic/kwin6-bismuth-decoration/pull/3 is merged
    owner = "casept";
    repo = "kwin6-bismuth-decoration";
    rev = "857731860de66b2f5803022c952d576310934ce0";
    sha256 = "sha256-iANKNwzmD7BORsM9AQygjuSpWMfLfIxXRkr6JVkCvzI=";
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
