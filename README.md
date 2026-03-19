# actrun-overlay

A Nix Flake overlay for building [actrun](https://github.com/mizchi/actrun) with Nix.
Includes patched Nix modules that fix bugs in [moonbit-overlay](https://github.com/moonbit-community/moonbit-overlay).

## Bug Fixes

This overlay includes the following bug fixes for `moonbit-overlay`:

- **listAllDependencies.nix** — Fixed `head.name` to `"${head.name}"` (Nix attribute key syntax bug), and added deduplication by name+version
- **buildCachedRegistry.nix** — Avoided file conflicts by using `cp -n` (no-clobber)
- **bundleWithRegistry.nix** — Changed `--source-dir` to `--target-dir` (compatibility with newer moon CLI)
- **buildMoonPackage.nix** — Changed build output directory from `target/` to `_build/`

## Usage

### As an Overlay

Add the following to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    actrun-overlay = {
      url = "github:myuron/actrun-overlay";
    };
  };

  outputs = { nixpkgs, actrun-overlay, ... }:
    let
      system = "x86_64-linux"; # or "aarch64-darwin"
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            actrun = actrun-overlay.packages.${system}.default;
          })
        ];
      };
    in
    {
      # Use as a package
      packages.${system}.default = pkgs.actrun;

      # Use in a devShell
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.actrun ];
      };
    };
}
```

### As a Direct Package Reference

You can also reference the package directly without using an overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    actrun-overlay = {
      url = "github:myuron/actrun-overlay";
    };
  };

  outputs = { nixpkgs, actrun-overlay, ... }:
    let
      system = "x86_64-linux";
    in
    {
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = [
          actrun-overlay.packages.${system}.default
        ];
      };
    };
}
```

### Run Directly with `nix run`

```bash
nix run github:myuron/actrun-overlay
```

## Supported Platforms

- `x86_64-linux`
- `aarch64-darwin`

## License

actrun itself is licensed under [Apache-2.0](https://github.com/mizchi/actrun/blob/main/LICENSE).
