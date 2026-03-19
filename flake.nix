{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    moonbit-overay = {
      url = "github:moonbit-community/moonbit-overlay";
    };

    moon-registry = {
      url = "git+https://mooncakes.io/git/index";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { inputs', system, pkgs, ... }:
        let
          moonbitSrc = inputs.moonbit-overay;

          # Reconstruct moonPlatform with patched listAllDependencies
          # Workaround for https://github.com/moonbit-community/moonbit-overlay
          # dedup bug in listAllDependencies.nix (head.name vs "${head.name}")
          versions = import "${moonbitSrc}/versions.nix" pkgs.lib;
          inherit (import "${moonbitSrc}/lib/utils.nix" { inherit (pkgs) stdenv lib; })
            mkToolChainsUri mkCoreUri target;

          moon-patched = pkgs.callPackage "${moonbitSrc}/lib/moon-patched" {
            rev = versions.latest.moonRev;
            hash = versions.latest.moonHash;
          };

          toolchains = pkgs.callPackage "${moonbitSrc}/lib/toolchains.nix" {
            version = "latest";
            inherit moon-patched;
            url = mkToolChainsUri "latest";
            hash = versions.latest."${target}-toolchainsHash";
          };

          core = pkgs.callPackage "${moonbitSrc}/lib/core.nix" {
            version = "latest";
            url = mkCoreUri "latest";
            hash = versions.latest.coreHash;
          };

          parseMoonIndex = import "${moonbitSrc}/lib/moonPlatform/parseMoonIndex.nix" {
            inherit (pkgs) lib;
          };

          listAllDependencies = import ./nix/listAllDependencies.nix {
            inherit parseMoonIndex;
            inherit (pkgs) lib;
          };

          fetchMoonPackage = import "${moonbitSrc}/lib/moonPlatform/fetchMoonPackage.nix" {
            inherit (pkgs) fetchurl;
          };

          buildCachedRegistry = import ./nix/buildCachedRegistry.nix {
            inherit (pkgs) lib stdenv;
            inherit fetchMoonPackage listAllDependencies;
          };

          bundleWithRegistry = import ./nix/bundleWithRegistry.nix {
            inherit (pkgs) symlinkJoin makeWrapper;
            inherit toolchains core;
          };

          buildMoonPackage = import ./nix/buildMoonPackage.nix {
            inherit (pkgs) lib stdenv;
            inherit buildCachedRegistry bundleWithRegistry;
          };
          actrunSrc = inputs'.actrun or (pkgs.fetchFromGitHub {
            owner = "mizchi";
            repo = "actrun";
            rev = "v0.2.1";
            hash = "sha256-broIRto8qQvHizm1JF8uVTjJuyZWLP73qkLQGaZGOJU=";
          });
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
          };

          packages.default = buildMoonPackage {
            name = "actrun";
            src = actrunSrc;
            version = "0.2.1";
            moonModJson = "${actrunSrc}/moon.mod.json";
            moonRegistryIndex = inputs.moon-registry;
            moonFlags = [ "--release" "--target" "native" ];
            installPhase = ''
              mkdir -p $out/bin
              cp $TMP/_build/native/release/build/cmd/actrun/actrun.exe $out/bin/actrun
            '';
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    };
}
