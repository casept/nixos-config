{ stdenv, lib, fetchurl, obinskit }:

# TODO: Submit fix to nixpkgs
obinskit.overrideDerivation (old: {
    src = fetchurl {
      url = "https://annepro.s3.amazonaws.com/4-tar-gz.tar";
      sha256 = "sha256-4jL9/0zvKEe0IbAcSQXuqoYGVX6VCAgI/NaQisN26RM=";
    };
    unpackPhase = "tar -xvf $src";
})