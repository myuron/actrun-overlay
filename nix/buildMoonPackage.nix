# Patched version of moonbit-overlay's buildMoonPackage.nix
# Fix: moon build output directory changed from target/ to _build/
{
  lib,
  stdenv,
  buildCachedRegistry,
  bundleWithRegistry,
  ...
}:
let
  buildMoonPackage =
    {
      moonModJson,
      moonRegistryIndex,
      moonFlags ? [ ],
      ...
    }@args:
    let
      cachedRegistry = buildCachedRegistry {
        inherit moonModJson;
        registryIndexSrc = moonRegistryIndex;
      };
      moonHome = bundleWithRegistry {
        inherit cachedRegistry;
      };
      nativeBuildInputs = lib.lists.unique ((args.nativeBuildInputs or [ ]) ++ [ moonHome ]);
      unpackPhase = ''
        mkdir -p $TMP
        cp -r $src/* $TMP
      '';
      buildPhase = ''
        cd $TMP
        moon build ${lib.concatStringsSep " " moonFlags}
      '';
      installPhase = ''
        mkdir -p $out
        cp -r $TMP/_build/ $out/
      '';
      env = (args.env or { }) // {
        MOON_HOME = "${moonHome}";
      };
    in
    stdenv.mkDerivation (
      {
        inherit
          nativeBuildInputs
          unpackPhase
          buildPhase
          installPhase
          env
          ;
      }
      // args
    );
in
buildMoonPackage
