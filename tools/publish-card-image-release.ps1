param(
  [string]$Repository = 'gumiajer21/card-decoder-web',
  [string]$Tag = 'card-image-zh-v1',
  [string]$Assets = '..\release-assets\card-images-zh-v1'
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetPath = [System.IO.Path]::GetFullPath((Join-Path $scriptDir $Assets))
$files = @(Get-ChildItem -LiteralPath $assetPath -File | Where-Object { $_.Extension -eq '.zip' -or $_.Name -eq 'manifest.json' } | Sort-Object Name)

if ($files.Count -ne 101) { throw "Expected 100 ZIP packs and manifest.json, found $($files.Count) files in $assetPath" }
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI (gh) is not installed or not in PATH.' }

gh release view $Tag --repo $Repository *> $null
if ($LASTEXITCODE -ne 0) {
  gh release create $Tag --repo $Repository --title '中文高清卡图 v1' --notes '卡片解码者网页版按需加载的中文高清卡图分包。'
  if ($LASTEXITCODE -ne 0) { throw 'Failed to create GitHub Release.' }
}

for ($index = 0; $index -lt $files.Count; $index++) {
  $file = $files[$index]
  Write-Progress -Activity 'Uploading card image packs' -Status "$($index + 1) / $($files.Count): $($file.Name)" -PercentComplete ([int](100 * ($index + 1) / $files.Count))
  gh release upload $Tag $file.FullName --repo $Repository --clobber
  if ($LASTEXITCODE -ne 0) { throw "Upload failed: $($file.Name)" }
}
Write-Progress -Activity 'Uploading card image packs' -Completed
Write-Output "Published $($files.Count) assets to $Repository release $Tag"
