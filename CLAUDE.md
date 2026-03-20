# CLAUDE.md

## 概要
nixpkgsに公開されていないOSSをnixでinstallできるように、
flake.nixにoverlayを組み込む。

## 対象
https://github.com/mizchi/actrun

## 処理概要
1. GitHubのreleasesからtar.gzをダウンロード
  - https://github.com/mizchi/actrun/releases/download/v0.21.3/actrun-linux-x64.tar.gz
  - https://github.com/mizchi/actrun/releases/download/v0.21.3/actrun-macos-arm64.tar.gz
2. tar.gzを解答し、nix-storeに配置する

## 運用保守
- releasesの更新に追従するために、GitHub Actionsをcronで実行し、versionup及びHash更新を行う

## ToDo
- [x] nixファイルの作成
- [x] build確認
- [x] dev/flake.nixを作成し、overlayを注入できるか確認
- [x] GitHub Actions用のymlを作成する
