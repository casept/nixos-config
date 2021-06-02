# From https://github.com/CrazedProgrammer/nix/blob/71f41fe9fd3d1702f5d23e4a34c66612e53435d5/pkgs/custom/technic-launcher.nix
{ stdenv, lib, fetchurl, makeWrapper, jre, openal }:

let version = "4.625";

in stdenv.mkDerivation {
  pname = "technic-launcher";
  version = version;

  jar = fetchurl {
    url = "http://launcher.technicpack.net/launcher${
        lib.replaceStrings [ "." ] [ "/" ] version
      }/TechnicLauncher.jar";
    sha256 = "sha256-oHBHWRO7/Lkr/AqWHo7V9eukUqaySZj4FgvEaUeIl/Y=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openal ];

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/share/java
    ln -s $jar $out/share/java/technic.jar
    makeWrapper ${jre}/bin/java $out/bin/technic --add-flags "-jar $out/share/java/technic.jar" --prefix LD_LIBRARY_PATH : ${openal}/lib
  '';

  meta = with lib; {
    description = "Minecraft Mod Launcher";
    homepage = "https://www.technicpack.net/";
  };
}
