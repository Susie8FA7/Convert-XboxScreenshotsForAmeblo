# Convert-XboxScreenshotsForSNS

XboxスクリーンショットPNGを、
Amebaブログなど、SNS投稿用にJPGへ変換するPowerShellスクリプトです。


サイズ変更とファイル形式変更をしているだけなので、他のSNS用にも使えます。


OneDriveの容量節約のため、変換処理後に元フォルダから退避フォルダに画像ファイルを移動します。

※ 変換後、元のPNG/JXRファイルは退避フォルダへ移動されます。元フォルダに残したい場合は、移動処理をコメントアウトしてください。


Xbox HDRスクリーンショット運用を、
PowerShellとWindows標準機能だけで自動化することを目的に作成しました。

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

### Xbox console screenshots via OneDrive(Japanese Windows)

```powershell
$InputFolder = "C:\Users\(ユーザー名)\OneDrive\画像\Xbox Screenshots"
```

### Xbox console screenshots via OneDrive(English)

```powershell
$InputFolder = "C:\Users\(UserName)\OneDrive\Pictures\Xbox Screenshots"
```

### PC Game screenshots

```powershell
$InputFolder = "D:\Users\(UserName)\Videos\Captures"
```

### Output folder

```powershell
$OutputFolder = "D:\SNS"
```

### Archive folder(original PNG/JXR files are moved here after conversion)

```powershell
$ArchiveFolder = "\\NAS\share\XboxScreenshotsArchive"
```

### Target title

Example: Forza Horizon 6 only

```powershell
$FileNamePrefix = "Forza Horizon 6"
```


Example: All Titles

```powershell
$FileNamePrefix = ""
```

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
