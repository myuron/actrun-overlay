# actrun-overlay

Nix overlay for installing [actrun](https://github.com/mizchi/actrun).

## Usage

### Adding the overlay to your flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    actrun-overlay.url = "github:myuron/actrun-overlay";
  };

  outputs = { nixpkgs, actrun-overlay, ... }:
    let
      system = "x86_64-linux"; # or "aarch64-darwin"
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ actrun-overlay.overlays.default ];
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

### Supported platforms

- `x86_64-linux`
- `aarch64-darwin`
