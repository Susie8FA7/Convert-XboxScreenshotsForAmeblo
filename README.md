# Convert-XboxScreenshotsForAmeblo

XboxスクリーンショットPNGを、
Amebaブログ投稿用JPGへ変換するPowerShellスクリプトです。
サイズ変更とファイル形式変更をしているだけなので、他のブログ用にも使えます。
OneDriveの容量節約のため、変換処理後に元フォルダから退避フォルダに画像ファイルを移動します。
Xbox HDRスクリーンショット運用を、
PowerShellとWindows標準機能だけで自動化することを目的に作成しました。
コード例は「Forza Horizon 6」対応になっていますが
コード内の $FileNamePrefixの中身を変更することで、他のタイトルにも対応します。
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

## Usage

1. ps1内の設定値を変更
2. PowerShellで実行
3. 必要に応じてタスクスケジューラーへ登録

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
