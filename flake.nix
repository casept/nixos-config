{
  description = "casept's completely stable and well thought-out system config";

  inputs = {
    # Used by the core system config
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # TODO: Switch back once all machines are merged
    nixos-hardware.url = "github:casept/nixos-hardware";
    # Used by the dev shell
    flake-utils.url = "github:numtide/flake-utils";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      flake = false;
    };

    # Used by home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , comma
    , nixos-vsliveshare
    , nix-flatpak
    , ...
    }:
    let
      system = "x86_64-linux";
      overlay-unstable = self: super: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.allowBroken = true;
        };
      };
    in
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1

              nix-flatpak.nixosModules.nix-flatpak

              (import ./boxes/laptop.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager nixos-vsliveshare;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
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

      nixosConfigurations.twods = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.gpd-micropc

              nix-flatpak.nixosModules.nix-flatpak

              (import ./boxes/2ds.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager nixos-vsliveshare;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
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

      nixosConfigurations.clobus = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager

              nix-flatpak.nixosModules.nix-flatpak

              (import ./boxes/clobus.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager nixos-vsliveshare;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
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

      nixosConfigurations.fakepi = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              (import ./boxes/fakepi.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  ;
              })
              (import ./common/flake-conf.nix {
                inherit pkgs nixpkgs nixpkgs-unstable;
              })
            ];
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowBroken = true;
            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
      };
    };
}
