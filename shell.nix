let
  # Use a pinned nixpkgs version with niv
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs { };
  niv = import sources.niv { };
  ng = import sources.nixos-generators { };
  nix-linter = import sources.nix-linter { };
  shellPackages = [
    nixpkgs.nixops
    sources.nixos-shell
    ng
    niv.niv
    nix-linter.nix-linter
    nixpkgs.nixops
  ];
in nixpkgs.mkShell { buildInputs = shellPackages; }
