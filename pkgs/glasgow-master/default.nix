{ lib
, python3Packages
, fetchFromGitHub
, fetchPypi
, cmake
, glasgow
}:

let
  pyccobs = python3Packages.buildPythonPackage {
    pname = "pyccobs";
    version = "0.1.1";
    pyproject = true;

    src = fetchPypi {
      pname = "pyccobs";
      version = "0.1.1";
      hash = "sha256-uLXua5SNY0ySCQnjyDZvJtlPw5O30tezJn1fmwdZomw=";
    };

    nativeBuildInputs = [ cmake ];
    build-system = [ python3Packages.setuptools ];
    dontUseCmakeConfigure = true;

    meta = {
      description = "Portable ctypes bindings for ccobs";
      homepage = "https://github.com/Elizafox/pyccobs";
      license = lib.licenses.bsd0;
    };
  };

  rev = "70cb38c9b03471acd2eabb76c82308891bec2ca5";
  shortRev = builtins.substring 0 7 rev;
  version = "0-unstable-2026-11-06";
  pdmVersion = "0.1.dev0+g${shortRev}";

  glasgowDeps = [ pyccobs ] ++ (with python3Packages; [
    fx2
    aiohttp
    amaranth
    colorama
    enum-tools
    importlib-resources
    libusb1
    packaging
    platformdirs
    pyvcd
    typing-extensions
    tqdm
  ]);
in
glasgow.overrideAttrs (old: {
  pname = "glasgow-master";
  inherit version;

  src = fetchFromGitHub {
    owner = "GlasgowEmbedded";
    repo = "glasgow";
    inherit rev;
    hash = "sha256-nnLSwqI5WwS5B7rB5TWj47FJU2RuAwQiPLw0Dsxs2NY=";
  };

  # The original preBuild compiles FX2 firmware to verify it matches the
  # checked-in blob byte-for-byte. This requires the exact same sdcc version
  # upstream used (4.6.0) and is not essential – the checked-in blob is
  # what gets loaded at runtime. Skip the firmware build to avoid sdcc
  # version sensitivity; just set the SCM version for the Python build.
  preBuild = ''
    cd software
    export PDM_BUILD_SCM_VERSION="${pdmVersion}"
  '';

  dependencies = glasgowDeps;

  # Also need them in propagatedBuildInputs so the build-time environment
  # (and pythonRuntimeDepsCheckHook) can find them.
  propagatedBuildInputs = glasgowDeps;

  # pyvcd<0.5 not satisfied by nixpkgs 0.5.x
  pythonRelaxDeps = [ "pyvcd" ];

  passthru = (old.passthru or { }) // {
    updateScript = null;
  };

  meta = old.meta // {
    version = version;
  };
})
