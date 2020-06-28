# The version in nixpkgs is the latest release, but it's not compatible with new bitlocker features.

with import <nixpkgs> { };

stdenv.mkDerivation rec {
  pname = "dislocker-master";
  version = "master";

  src = fetchFromGitHub {
    owner = "aorimn";
    repo = "dislocker";
    rev = "339733f0bda09fd84ae20d9c1b4e7c501ca203e5";
    sha256 = "18170ibq1nddisk717l18ggd3cr5f7ilj3ax5rzgj0ywg7m1l7wg";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ fuse mbedtls ];

  meta = with stdenv.lib; {
    description = "Read BitLocker encrypted partitions in Linux";
    homepage = "https://github.com/aorimn/dislocker";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
