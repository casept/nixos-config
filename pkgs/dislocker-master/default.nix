# The version in nixpkgs is the latest release, but it's not compatible with new bitlocker features.

{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, fuse, mbedtls_2 }:
stdenv.mkDerivation {
  pname = "dislocker-master";
  version = "master";

  src = fetchFromGitHub {
    owner = "aorimn";
    repo = "dislocker";
    rev = "845e20c76147b12f52be531b34242922a0661771";
    sha256 = "sha256-ckJVaGPINuLepnUfV6usWpYTx8pPWQihnWXdVk7I+H0=";
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
