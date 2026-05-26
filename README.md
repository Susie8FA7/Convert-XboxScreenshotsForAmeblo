# Convert-XboxScreenshotsForSNS

XboxスクリーンショットPNGを、
Amebaブログなど、SNS投稿用にJPGへ変換するPowerShellスクリプトです。


サイズ変更とファイル形式変更をしているだけなので、他のSNS用にも使えます。


OneDriveの容量節約のため、変換処理後に元フォルダから退避フォルダに画像ファイルを移動します。

※ 変換後、元のPNG/JXRファイルは退避フォルダへ移動されます。元フォルダに残したい場合は、移動処理をコメントアウトしてください。


Xbox HDRスクリーンショット運用を、
PowerShellとWindows標準機能だけで自動化することを目的に作成しました。


コードの変更箇所例：

`$InputFolder`の中身は、スクリーンショットファイルが入っているフォルダのパスを指定します。

Xboxコンソールの場合の例：「C:\Users\\(PCのログインユーザー名)\OneDrive\画像\Xbox Screenshots」

PCのXboxストアのゲームの場合の例：「(Windowsの新しい写真とビデオの保存先ドライブ):\Users\\(PCのログインユーザー名)\Videos\Captures」


`$OutputFolder`の中身は、SNS投稿用に変換したJPGファイルを出力するフォルダのパスを指定します。


`$ArchiveFolder`の中身は、変換前のスクリーンショットファイルを、バックアップするパスを指定します。
NASなど容量に余裕のある場所を指定するのが、おすすめです！


`$FileNamePrefix`の中身は、「Forza Horizon 6」対応になっていますが、
スクリーンショットファイル名の頭に入る、他のゲームタイトルに変更することで、いろいろなタイトルに対応します。

空文字にすると、全タイトル(Xboxスクリーンショット全体)に対応します。

## Features

- PNG → JPG変換
- 横幅1920pxへ縮小
- JPEG品質90
- UTCファイル名をJSTへ変換
- OneDriveクラウドファイル検知
- PNG/JXRファイルをNAS等へ退避
- Windows標準機能のみ使用

## Requirements

- Windows 11
- PowerShell 5.1以上
- Windows 11 標準機能の Windows Imaging Component (WIC)

## Configuration

### Xbox console screenshots via OneDrive

$InputFolder = "C:\Users\(UserName)\OneDrive\画像\Xbox Screenshots"

### PC Game screenshots

$InputFolder = "D:\Users\(UserName)\Videos\Captures"

### Output folder

$OutputFolder = "D:\SNS"

### Archive folder

$ArchiveFolder = "\\NAS\share\XboxScreenshotsArchive"

### Target title

$FileNamePrefix = "Forza Horizon 6"

## Usage

1. ps1内の設定値を変更
2. PowerShellで実行
3. 必要に応じてタスクスケジューラーへ登録

## History

2026-05-26
Repository renamed from
Convert-XboxScreenshotsForAmeblo
to
Convert-XboxScreenshotsForSNS

## Disclaimer

本スクリプトの使用によって発生したデータ消失・破損等について、
作者は責任を負いません。

利用前に必ずバックアップを取得し、
内容を理解した上で自己責任で使用してください。

Use this script at your own risk.

The author is not responsible for any data loss or damage caused by the use of this script.

Please back up your files before use.

## License

MIT
