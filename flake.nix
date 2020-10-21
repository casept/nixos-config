{
  description = "casept's completely stable and well thought-out system config";

  inputs = {
    # Used by the core system config
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Used by the dev shell
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      flake = false;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used by home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:Shopify/comma";
      flake = false;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vsliveshare = {
      url = "github:msteen/nixos-vsliveshare";
      flake = false;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager
    , comma, nixos-vsliveshare, ... }:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.casept-x230t = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, config, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.lenovo-thinkpad-x230

              (import ./boxes/casept-x230t.nix {
                inherit pkgs lib nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager comma nixos-vsliveshare;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config.allowUnfree = true;
            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };

      nixosConfigurations.t400-homeserver = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, config, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.common-cpu-intel
              nixos-hardware.nixosModules.common-pc-laptop-hdd
              nixos-hardware.nixosModules.common-pc-laptop

              (import ./boxes/t400-homeserver.nix {
                inherit config pkgs lib nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager comma nixos-vsliveshare;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config.allowUnfree = true;
            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };
      # TODO: Load dev shell with tools for working on this config
    };
}
