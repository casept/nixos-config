let
  # Use a pinned nixpkgs version with niv
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs { };
  ng = import sources.nixos-generators { };
  shellPackages = [
    nixpkgs.nixops
    sources.nixos-shell
    ng
  ];
in nixpkgs.mkShell { buildInputs = shellPackages; }
