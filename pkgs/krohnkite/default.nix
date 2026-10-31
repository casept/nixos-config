{ lib, nix-update-script, buildNpmPackage, fetchFromCodeberg, nodejs_22, kdePackages, zip }:
buildNpmPackage (finalAttrs: {
  pname = "krohnkite";
  version = "0.9.10.0-alpha-unstable-2026-10-30";

  src = fetchFromCodeberg {
    owner = "anametologin";
    repo = "Krohnkite";
    rev = "112884b1642001a06fc3853062bcc9df9a18de86";
    hash = "sha256-mrqxkoYJTkhbj998xpefj3/X+TsAUVL90v6TDV2xAP4=";
  };

  npmDepsHash = "sha256-MCfG0C+h2VC/eKO2Js31vrCt0AXTGrkXptwKjdQzwLQ=";

  dontWrapQtApps = true;

  nodejs = nodejs_22;

  nativeBuildInputs = [
    kdePackages.kpackage
    zip
    kdePackages.kwin
  ];

  npmBuildScript = "tsc";

  installPhase = ''
    runHook preInstall

    substituteInPlace Makefile --replace-fail '7z a -tzip' 'zip -r'
    # Override PROJECT_VER and PROJECT_REV because we don't have .git
    make \
      KWINPKG_FILE=krohnkite.kwinscript \
      PROJECT_REV=112884b \
      PROJECT_VER=${finalAttrs.version} \
      krohnkite.kwinscript
    kpackagetool6 --type=KWin/Script --install=krohnkite.kwinscript --packageroot=$out/share/kwin/scripts

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dynamic Tiling Extension for KWin 6";
    homepage = "https://codeberg.org/anametologin/Krohnkite";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
