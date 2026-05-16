#requires -version 5.1
<#
Converts Xbox screenshot PNG files for Ameba blog posting.

This script uses Windows Imaging Component (WIC) through .NET/WPF classes
included with Windows 11. It does not use external modules, ImageMagick, or
additional software.
#>

# XboxスクリーンショットPNGが保存されるOneDriveフォルダ
$InputFolder = 'OneDrive上のXboxScreenShotsフォルダを指定してください'

# Ameblo投稿用JPGの出力先フォルダ
$OutputFolder = 'ブログ用jpgファイルの出力先フォルダを指定してください'

# 元PNG/JXRファイルを退避するNASフォルダ
$ArchiveFolder = 'NAS上のフォルダなど、退避用の場所を指定してください'

# スクリーンショットファイルの頭に入る、ゲームタイトルを指定。今回は'Forza Horizon 6'
$FileNamePrefix = 'Forza Horizon 6'

# JPG最大横幅
$MaxWidth = 1920

# JPG品質 (0-100)
$JpegQuality = 90

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
}

function Test-WicAvailable {
    try {
        Add-Type -AssemblyName PresentationCore -ErrorAction Stop
        Add-Type -AssemblyName WindowsBase -ErrorAction Stop

        $null = [System.Windows.Media.Imaging.BitmapImage]
        $null = [System.Windows.Media.Imaging.JpegBitmapEncoder]
        return $true
    }
    catch {
        Write-Log 'Windows Imaging APIs / WIC を .NET から利用できません。'
        Write-Log 'Windows 11 標準機能として利用する想定のため、追加ソフトは不要です。'
        Write-Log '.NET Framework / WPF 関連コンポーネント、または Windows の状態を確認してください。'
        Write-Log '確認例: 「Windows の機能の有効化または無効化」で .NET Framework 4.x 系が利用可能か確認します。'
        Write-Log "詳細: $($_.Exception.Message)"
        return $false
    }
}

function Convert-UtcTimestampInBaseNameToJst {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseName
    )

    $timestampPattern = '\d{4}_\d{2}_\d{2}-\d{2}-\d{2}-\d{2}'
    $timestampMatch = [regex]::Match($BaseName, $timestampPattern)

    if (-not $timestampMatch.Success) {
        return $BaseName
    }

    $utcTimestamp = [datetime]::ParseExact(
        $timestampMatch.Value,
        'yyyy_MM_dd-HH-mm-ss',
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None
    )
    $jstTimestamp = $utcTimestamp.AddHours(9).ToString(
        'yyyy_MM_dd-HH-mm-ss',
        [System.Globalization.CultureInfo]::InvariantCulture
    )

    return $BaseName.Remove($timestampMatch.Index, $timestampMatch.Length).Insert($timestampMatch.Index, $jstTimestamp)
}

function Get-OutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$SourceFile
    )

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile.Name)
    $baseName = Convert-UtcTimestampInBaseNameToJst -BaseName $baseName
    return Join-Path -Path $OutputFolder -ChildPath ($baseName + '.jpg')
}

function Test-IsOneDriveCloudFileError {
    param(
        [Parameter(Mandatory = $true)]
        [System.Exception]$Exception
    )

    return ($Exception.Message -like '*クラウド ファイル*') -or
        ($Exception.Message -like '*cloud file*')
}

function Convert-ToAmebloJpeg {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$SourceFile,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    $inputStream = $null
    $outputStream = $null

    try {
        $inputStream = [System.IO.File]::Open(
            $SourceFile.FullName,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::Read
        )

        $decoder = [System.Windows.Media.Imaging.BitmapDecoder]::Create(
            $inputStream,
            [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
            [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        )

        $sourceFrame = $decoder.Frames[0]
        $sourceWidth = [int]$sourceFrame.PixelWidth
        $sourceHeight = [int]$sourceFrame.PixelHeight
        $outputFrame = $sourceFrame

        if ($sourceWidth -gt $MaxWidth) {
            $scale = $MaxWidth / $sourceWidth
            $newWidth = $MaxWidth
            $newHeight = [int][Math]::Round($sourceHeight * $scale)
            $transform = New-Object System.Windows.Media.ScaleTransform($scale, $scale)
            $resized = New-Object System.Windows.Media.Imaging.TransformedBitmap($sourceFrame, $transform)
            $outputFrame = [System.Windows.Media.Imaging.BitmapFrame]::Create($resized)

            Write-Log "RESIZE: '$($SourceFile.Name)' ${sourceWidth}x${sourceHeight} -> ${newWidth}x${newHeight}"
        }
        else {
            Write-Log "CONVERT: '$($SourceFile.Name)' ${sourceWidth}x${sourceHeight} -> JPG"
        }

        $encoder = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
        $encoder.QualityLevel = $JpegQuality
        $encoder.Frames.Add($outputFrame)

        $outputStream = [System.IO.File]::Open(
            $DestinationPath,
            [System.IO.FileMode]::CreateNew,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None
        )

        $encoder.Save($outputStream)
    }
    finally {
        if ($null -ne $outputStream) {
            $outputStream.Dispose()
        }

        if ($null -ne $inputStream) {
            $inputStream.Dispose()
        }
    }
}

function Move-SourceFilesToArchive {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$PngFile
    )

    $result = @{
        PngMoved = $false
        Warnings = 0
    }

    $pngArchivePath = Join-Path -Path $ArchiveFolder -ChildPath $PngFile.Name
    $jxrFileName = [System.IO.Path]::GetFileNameWithoutExtension($PngFile.Name) + '.jxr'
    $jxrSourcePath = Join-Path -Path $InputFolder -ChildPath $jxrFileName
    $jxrArchivePath = Join-Path -Path $ArchiveFolder -ChildPath $jxrFileName

    if (Test-Path -LiteralPath $pngArchivePath -PathType Leaf) {
        throw "NAS側に同名PNGが既にあるため、元PNGを移動できません: $pngArchivePath"
    }

    Move-Item -LiteralPath $PngFile.FullName -Destination $pngArchivePath -ErrorAction Stop
    Write-Log "MOVE: PNG '$($PngFile.Name)' -> '$pngArchivePath'"
    $result.PngMoved = $true

    if (-not (Test-Path -LiteralPath $jxrSourcePath -PathType Leaf)) {
        Write-Log "WARN: 同じベース名のJXRファイルが見つかりません: '$jxrFileName'"
        $result.Warnings++
        return $result
    }

    if (Test-Path -LiteralPath $jxrArchivePath -PathType Leaf) {
        Write-Log "WARN: NAS側に同名JXRが既にあるため、JXRの移動をスキップしました: '$jxrFileName'"
        $result.Warnings++
        return $result
    }

    try {
        Move-Item -LiteralPath $jxrSourcePath -Destination $jxrArchivePath -ErrorAction Stop
        Write-Log "MOVE: JXR '$jxrFileName' -> '$jxrArchivePath'"
    }
    catch {
        Write-Log "WARN: JXR '$jxrFileName' の移動に失敗しました。"
        Write-Log "詳細: $($_.Exception.Message)"
        $result.Warnings++
    }

    return $result
}

Write-Log '処理を開始します。'
Write-Log "入力フォルダ: $InputFolder"
Write-Log "出力フォルダ: $OutputFolder"
Write-Log "元ファイル移動先: $ArchiveFolder"
Write-Log "対象条件: ファイル名が '$FileNamePrefix' で始まる .png"
Write-Log '出力ファイル名: 元ファイル名内の UTC 日時 yyyy_MM_dd-HH-mm-ss を JST に変換します。'

if (-not (Test-WicAvailable)) {
    exit 1
}

if (-not (Test-Path -LiteralPath $InputFolder -PathType Container)) {
    Write-Log '入力フォルダが見つかりません。処理を終了します。'
    exit 1
}

if (-not (Test-Path -LiteralPath $OutputFolder -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $OutputFolder -Force -ErrorAction Stop | Out-Null
        Write-Log '出力フォルダを作成しました。'
    }
    catch {
        Write-Log '出力フォルダを作成できませんでした。処理を終了します。'
        Write-Log "詳細: $($_.Exception.Message)"
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $ArchiveFolder -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $ArchiveFolder -Force -ErrorAction Stop | Out-Null
        Write-Log '元ファイル移動先フォルダを作成しました。'
    }
    catch {
        Write-Log '元ファイル移動先フォルダを作成できませんでした。処理を終了します。'
        Write-Log "詳細: $($_.Exception.Message)"
        exit 1
    }
}

$filter = $FileNamePrefix + '*.png'
$files = @(Get-ChildItem -LiteralPath $InputFolder -File -Filter $filter | Sort-Object Name)

if ($files.Count -eq 0) {
    Write-Log '対象ファイルが見つかりませんでした。'
    Write-Log '処理が完了しました。変換: 0 / スキップ: 0 / エラー: 0 / 警告: 0'
    exit 0
}

$converted = 0
$skipped = 0
$failed = 0
$warnings = 0

foreach ($file in $files) {
    if (($file.Attributes -band [System.IO.FileAttributes]::Offline) -ne 0) {
        Write-Log "SKIP: '$($file.Name)' はクラウドのみのファイルのためスキップしました。"
        $skipped++
        continue
    }

    $outputPath = Get-OutputPath -SourceFile $file

    if (Test-Path -LiteralPath $outputPath -PathType Leaf) {
        Write-Log "SKIP: '$($file.Name)' は出力先に同名 JPG があるためスキップしました。"
        $skipped++
        continue
    }

    try {
        Convert-ToAmebloJpeg -SourceFile $file -DestinationPath $outputPath
        Write-Log "DONE: '$($file.Name)' -> '$outputPath'"
        $converted++

        try {
            $moveResult = Move-SourceFilesToArchive -PngFile $file
            $warnings += $moveResult.Warnings
        }
        catch {
            Write-Log "ERROR: JPG変換後、元PNG '$($file.Name)' のNAS移動に失敗しました。"
            Write-Log "詳細: $($_.Exception.Message)"
            $failed++
        }
    }
    catch {
        if (Test-IsOneDriveCloudFileError -Exception $_.Exception) {
            Write-Log "WAIT: '$($file.Name)' はOneDrive同期未完了のため次回再試行します。"
            $skipped++
            continue
        }

        Write-Log "ERROR: '$($file.Name)' の処理に失敗しました。"
        Write-Log "詳細: $($_.Exception.Message)"
        $failed++
    }
}

Write-Log "処理が完了しました。変換: $converted / スキップ: $skipped / エラー: $failed / 警告: $warnings"

if ($failed -gt 0) {
    exit 1
}
