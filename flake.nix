{
  description = "casept's completely stable and well thought-out system config";

  inputs = {
    # Used by the core system config
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # TODO: Switch back once l13 amd yoga gen2 is merged
    nixos-hardware.url = "github:casept/nixos-hardware";
    # Used by the dev shell
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      flake = false;
    };

    # Used by home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:Shopify/comma";
      flake = false;
    };
    # TODO: Switch back to upstream once flakeified
    nixos-vsliveshare = {
      url = "github:Flakebi/nixos-vsliveshare";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rnix-lsp-flake = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager
    , comma, nixos-vsliveshare, rnix-lsp-flake, ... }:
    let
      system = "x86_64-linux";
      overlay-unstable = self: super: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.allowBroken = true;
        };
      };
      # The Mullvad client in stable is outdated
      overlay-mullvad = self: super: {
        mullvad-vpn = super.unstable.pkgs.mullvad-vpn;
      };
      extra-pkgs = self: super:
        { # pkgs.comma = (super.callPackage comma { });
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
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager nixos-vsliveshare rnix-lsp-flake;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable overlay-mullvad extra-pkgs ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowBroken = true;
            nixpkgs.config.pipewire = true; # Needed for waybar PA widget
            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };

      nixosConfigurations.l13 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, config, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga-amd-gen2

              (import ./boxes/l13.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager nixos-vsliveshare rnix-lsp-flake;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable overlay-mullvad extra-pkgs ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowBroken = true;
            nixpkgs.config.pipewire = true; # Needed for waybar PA widget
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
                  home-manager comma nixos-vsliveshare rnix-lsp-flake;
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
