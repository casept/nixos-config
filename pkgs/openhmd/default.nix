{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, hidapi }:
# Removed from nixpkgs (unmaintained upstream), but still the only OpenHMD
# release that drives the Oculus Rift CV1 (3DoF). Resurrected locally so
# monado can be built with XRT_BUILD_DRIVER_OHMD.
stdenv.mkDerivation {
  pname = "openhmd";
  # No release since 0.3.0 (2020); master has much better CV1 support.
  version = "0.3.0-unstable-2025-01-13";

  src = fetchFromGitHub {
    owner = "OpenHMD";
    repo = "OpenHMD";
    rev = "85075b0c7e3c723ded2577edb79d00ee11aac339";
    hash = "sha256-TEnSewAiDZ8XtqpXqTpKz3IAP8C/zrAY0owXaSrv16g=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ hidapi ];

  cmakeFlags = [
    # Source declares cmake_minimum_required(VERSION 3.1), rejected by modern CMake.
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    # Monado has its own native rift-s driver with identical rift_s_* symbols;
    # leaving OpenHMD's enabled causes multiple-definition link errors in monado.
    # We only need OpenHMD for the CV1 (rift) driver.
    "-DOPENHMD_DRIVER_OCULUS_RIFT_S=OFF"
  ];

  meta = with lib; {
    description = "Free and open source API and drivers for immersive technology";
    homepage = "http://www.openhmd.net/";
    license = licenses.boost;
    platforms = platforms.linux;
  };
}
