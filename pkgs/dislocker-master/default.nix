# The version in nixpkgs is the latest release, but it's not compatible with new bitlocker features.

{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, fuse, mbedtls_2 }:
stdenv.mkDerivation {
  pname = "dislocker-master";
  version = "master";

  src = fetchFromGitHub {
    owner = "aorimn";
    repo = "dislocker";
    rev = "4572dc727940cc42249c9f967cee9c505f16b121";
    sha256 = "sha256-So5KpRR1fk+OG3saZRpNHXNJmsT5PRtkz89Te7WQhto=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ fuse mbedtls_2 ];

  meta = with lib; {
    description = "Read BitLocker encrypted partitions in Linux";
    homepage = "https://github.com/aorimn/dislocker";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
