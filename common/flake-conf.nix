{ nixpkgs, nixpkgs-unstable, pkgs, ... }: {
  system.stateVersion = "23.05";
  # Enable using the same nixpkgs commit in the imperative tools
  nix.registry = {
    nixpkgs.flake = nixpkgs;
    nixpkgs-unstable.flake = nixpkgs-unstable;
  };
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";
}
