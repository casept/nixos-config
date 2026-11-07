{
  description = "casept's completely stable and well thought-out system config";

  inputs = {
    # Used by the core system config
    # TODO: Switch to nixos-26.11 once out
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    opencode.url = "github:anomalyco/opencode/bf544cd419c5f17535c0d5af929f7ecd41188320";
    hister = {
      url = "github:asciimoo/hister";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
      # TODO: Switch once release-26.11 branch exists
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:Shopify/comma";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , comma
    , nix-flatpak
    , vpn-confinement
    , opencode
    , hister
    , ...
    }:
    let
      system = "x86_64-linux";
      # They don't sync their lockfile properly, override to fix that
      opencode' =
        let
          pkg = opencode.packages.${system}.opencode;
          node_modules = pkg.node_modules.override {
            hash = "sha256-Lk3dNKEm/iJ011b0gK2iIBxIUW/QEIALb9LHX49WUI0=";
          };
        in
        pkg.override { inherit node_modules; };
      overlay-unstable = self: super: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.allowBroken = true;
        };
        opencode = opencode';
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
                  home-manager;
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

      nixosConfigurations.komarik = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, pkgs, ... }: {
            imports = [
              # These should be imported in the hardware/role modules, but that causes infinite recursion
              home-manager.nixosModules.home-manager
              nixos-hardware.nixosModules.gpd-micropc

              nix-flatpak.nixosModules.nix-flatpak

              (import ./boxes/komarik.nix {
                inherit pkgs lib comma nixpkgs nixpkgs-unstable nixos-hardware
                  home-manager;
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
                  home-manager;
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
          home-manager.nixosModules.home-manager
          vpn-confinement.nixosModules.default
          hister.nixosModules.default

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
