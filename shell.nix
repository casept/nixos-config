let
  # Use a pinned nixpkgs version with niv
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs { };
  shellPackages = [
    nixpkgs.nixops
    sources.nixos-shell
  ];
in nixpkgs.mkShell { buildInputs = shellPackages; }
