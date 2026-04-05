param(
    [switch]$SkipReboot
)

$ErrorActionPreference = "Stop"

Write-Host "[1/5] Enable RDP & basic firewall rule..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "[2/5] Install Chocolatey..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "[3/5] Install dependencies (Java, VC++ runtime, Prism Launcher)..."
choco install -y temurin21jre vcredist140 prism-launcher

Write-Host "[4/5] Power settings for gaming performance..."
powercfg /setactive SCHEME_MIN
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0

Write-Host "[5/5] Optional Windows Defender exclusion for Minecraft folders..."
$paths = @("C:\Users\$env:USERNAME\AppData\Roaming\.minecraft", "C:\Minecraft")
foreach ($path in $paths) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
    Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
}

Write-Host "Done. Java + Prism Launcher installed."
Write-Host "Next: Open Prism Launcher, login Microsoft account, create instance và chơi game."

if (-not $SkipReboot) {
    Write-Host "System will reboot in 15 seconds..."
    Start-Sleep -Seconds 15
    Restart-Computer -Force
}
