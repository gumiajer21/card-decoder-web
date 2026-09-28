param(
  [string]$Source = "..\..\卡片解码者\dist\card-images-zh",
  [string]$Output = "..\release-assets\card-images-zh-v1",
  [string]$Version = "1"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = [System.IO.Path]::GetFullPath((Join-Path $scriptDir $Source))
$outputPath = [System.IO.Path]::GetFullPath((Join-Path $scriptDir $Output))

if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
  throw "Card image directory not found: $sourcePath"
}

[System.IO.Directory]::CreateDirectory($outputPath) | Out-Null
$packs = [System.Collections.Generic.List[object]]::new()
$totalFiles = 0
$totalBytes = [int64]0

foreach ($prefix in 0..99 | ForEach-Object { $_.ToString('00') }) {
  $sourceDir = Join-Path $sourcePath $prefix
  if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) { continue }

  $files = @(Get-ChildItem -LiteralPath $sourceDir -File | Sort-Object Name)
  if ($files.Count -eq 0) { continue }

  $assetName = "card-images-zh-$prefix.zip"
  $assetPath = Join-Path $outputPath $assetName
  if (Test-Path -LiteralPath $assetPath) {
    Remove-Item -LiteralPath $assetPath -Force
  }

  $archive = [System.IO.Compression.ZipFile]::Open($assetPath, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($file in $files) {
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $archive,
        $file.FullName,
        $file.Name,
        [System.IO.Compression.CompressionLevel]::NoCompression
      ) | Out-Null
    }
  }
  finally {
    $archive.Dispose()
  }

  $asset = Get-Item -LiteralPath $assetPath
  $hash = (Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash.ToLowerInvariant()
  $packs.Add([ordered]@{
    prefix = $prefix
    asset = $assetName
    fileCount = $files.Count
    bytes = $asset.Length
    sha256 = $hash
  })
  $totalFiles += $files.Count
  $totalBytes += $asset.Length
  Write-Progress -Activity 'Building card image packs' -Status "$prefix / 99" -PercentComplete ([int]$prefix)
}

$manifest = [ordered]@{
  schemaVersion = 1
  contentVersion = $Version
  format = 'zip-store'
  imageFormat = 'webp'
  shardRule = 'first-two-digits-of-zero-padded-8-digit-card-id'
  createdAt = (Get-Date).ToUniversalTime().ToString('o')
  totalFiles = $totalFiles
  totalBytes = $totalBytes
  packs = $packs
}

$manifestPath = Join-Path $outputPath 'manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding utf8
Write-Progress -Activity 'Building card image packs' -Completed
Write-Output "Created $($packs.Count) packs in $outputPath"
Write-Output "Manifest: $manifestPath"
