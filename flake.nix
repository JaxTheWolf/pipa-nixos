{
  description = "NixOS hardware configuration and flake for Xiaomi Pad 6 (pipa)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Internal base configuration for generating distribution images (not exported)
    baseSystem = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        self.nixosModules.default
        ./pkgs/base-configuration.nix
      ];
    };
    baseToplevel = baseSystem.config.system.build.toplevel;
  in {
    # Helper library functions for downstream flakes
    lib = {
      mkBuildImages = {
        pkgs,
        toplevel ? baseToplevel,
      }:
        pkgs.callPackage ./pkgs/build-images.nix {inherit toplevel;};

      mkBuildImagesApp = {
        pkgs,
        toplevel ? baseToplevel,
      }: let
        raw-script = self.lib.mkBuildImages {inherit pkgs toplevel;};
      in {
        type = "app";
        program = "${pkgs.writeShellScript "run-pipa-wrapper" ''
          echo "=> Requesting sudo to perform loopback mounts..."
          exec sudo ${raw-script}/bin/build-pipa-images "$@"
        ''}";
      };
    };

    # Overlay providing pipa packages
    overlays.default = import ./pkgs;

    # Packages
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
        config.allowUnfree = true;
      };
    in {
      inherit (pkgs) pipa-kernel pipa-firmware pipa-headers qbootctl-pipa;
      build-pipa-images = self.lib.mkBuildImages {
        inherit pkgs;
        toplevel = baseToplevel;
      };
      build-images = self.packages.${system}.build-pipa-images;
      default = pkgs.pipa-kernel;
    });

    # Apps
    apps = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      build-images = self.lib.mkBuildImagesApp {
        inherit pkgs;
        toplevel = baseToplevel;
      };
      raw = {
        type = "app";
        program = "${self.packages.${system}.build-images}/bin/build-pipa-images";
      };
      default = self.apps.${system}.build-images;
    });

    # NixOS Modules
    nixosModules = {
      default = import ./modules;
      pipa = self.nixosModules.default;
      xiaomi-pad-6 = self.nixosModules.default;
    };
  };
}
