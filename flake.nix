{
  description = "A startup basic MoonBit project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    moonbit-overlay.url = "github:moonbit-community/moonbit-overlay";
    actrun = {
      url = "github:mizchi/actrun";
      flake = false;
    };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem = { inputs', system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.moonbit-overlay.overlays.default ];
        };

        packages.default = pkgs.moonPlatform.buildMoonPackage {
          name = "actrun";
          src = inputs.actrun;
          version = "0.1.0";
          moonModJson = "${inputs.actrun}/moon.mod.json";
          moonRegistoryIndex = inputs.moon-registry;
          moonFlags = [ "--release" "--target" "native" ];
        };

        flake = {
          overlays.default = final: prev: {
            actrun = final.moonPlatform.buildMoonPackage {
              name = "actrun";
              src = inputs.actrun-src;
              version = "0.1.0";
              moonModJson = "${inputs.actrun}/moon.mod.json";
              moonRegistryIndex = inputs.moon-registry;
              moonFlags = [ "--release" "--target" "native" ];
            };
          };
        };

        devshells.default = {
            packages = with pkgs; [
              moonbit-bin.moonbit.latest
            ];
          };
      };

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
}
