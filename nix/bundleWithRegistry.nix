# Patched version of moonbit-overlay's bundleWithRegistry.nix
# Fix: --source-dir changed to --target-dir in newer moon CLI
{
  symlinkJoin,
  makeWrapper,
  toolchains,
  core,
}:
{
  cachedRegistry,
}:

symlinkJoin {
  name = "moonPlatform-moonHome";
  paths = [
    toolchains
    core
    cachedRegistry
  ];

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    export MOON_HOME=$out

    cd $out/lib/core
    PATH=$out/bin $out/bin/${toolchains.meta.mainProgram} bundle --all --target-dir $out/lib/core/_build

    wrapProgram $out/bin/${toolchains.meta.mainProgram} \
      --set MOON_HOME $out
  '';
}
