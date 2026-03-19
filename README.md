# actrun-overlay

[actrun](https://github.com/mizchi/actrun) を Nix でビルドするための Flake overlay。
[moonbit-overlay](https://github.com/moonbit-community/moonbit-overlay) のバグを修正したパッチ版 Nix モジュールを含みます。

## 修正内容

`moonbit-overlay` に対する以下のバグ修正を含みます:

- **listAllDependencies.nix** — `head.name` を `"${head.name}"` に修正（Nix の属性キー構文バグ）、および name+version での重複排除
- **buildCachedRegistry.nix** — `cp -n`（上書きなし）によるファイル競合の回避
- **bundleWithRegistry.nix** — `--source-dir` を `--target-dir` に変更（新しい moon CLI への対応）
- **buildMoonPackage.nix** — ビルド出力ディレクトリを `target/` から `_build/` に変更

## 使い方

### Overlay として利用する

`flake.nix` に以下のように設定します:

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
      system = "x86_64-linux"; # または "aarch64-darwin"
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
      # パッケージとして利用
      packages.${system}.default = pkgs.actrun;

      # devShell で利用
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.actrun ];
      };
    };
}
```

### 直接パッケージとして利用する

overlay を使わず、直接参照することもできます:

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

### `nix run` で直接実行する

```bash
nix run github:myuron/actrun-overlay
```

## 対応プラットフォーム

- `x86_64-linux`
- `aarch64-darwin`

## ライセンス

actrun 本体は [Apache-2.0](https://github.com/mizchi/actrun/blob/main/LICENSE) ライセンスです。
