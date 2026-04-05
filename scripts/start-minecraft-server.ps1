param(
    [string]$McVersion = "1.20.6",
    [string]$ServerDir = "C:\mc-server",
    [string]$Memory = "6G"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java chưa được cài. Hãy chạy setup-minecraft-vps.ps1 trước."
}

New-Item -Path $ServerDir -ItemType Directory -Force | Out-Null
Set-Location $ServerDir

$manifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
$manifest = Invoke-RestMethod -Uri $manifestUrl
$versionMeta = $manifest.versions | Where-Object { $_.id -eq $McVersion } | Select-Object -First 1

if (-not $versionMeta) {
    Write-Error "Không tìm thấy version $McVersion trong version manifest."
}

$detail = Invoke-RestMethod -Uri $versionMeta.url
$serverJar = Join-Path $ServerDir "server.jar"
Invoke-WebRequest -Uri $detail.downloads.server.url -OutFile $serverJar

"eula=true" | Out-File -Encoding ascii -FilePath (Join-Path $ServerDir "eula.txt") -Force

$runBat = @"
@echo off
java -Xms$Memory -Xmx$Memory -jar server.jar nogui
pause
"@
$runBat | Out-File -Encoding ascii -FilePath (Join-Path $ServerDir "run.bat") -Force

Write-Host "Server đã sẵn sàng tại $ServerDir"
Write-Host "Chạy: $ServerDir\run.bat"
