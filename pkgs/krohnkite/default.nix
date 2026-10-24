{ lib, nix-update-script, buildNpmPackage, fetchFromCodeberg, nodejs_22, kdePackages, zip }:
buildNpmPackage (finalAttrs: {
  pname = "krohnkite";
  version = "0.9.10.0-alpha-unstable-2026-10-22";

  src = fetchFromCodeberg {
    owner = "anametologin";
    repo = "Krohnkite";
    rev = "0f2f47bdfb7069aff34a5820a338442321356668";
    hash = "sha256-Zoe1XDw9SAsriVw3lZXSs7BzWCLjPy+sJFJFP27TSdk=";
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
      PROJECT_REV=0f2f47b \
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
