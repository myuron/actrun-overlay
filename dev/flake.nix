{
  description = "Development flake to test actrun-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    actrun-overlay.url = "path:..";
  };

  outputs =
    { nixpkgs, actrun-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ actrun-overlay.overlays.default ];
      };
    in
    {
      packages.${system}.default = pkgs.actrun;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.actrun ];
      };
    };
}
