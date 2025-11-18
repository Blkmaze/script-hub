<# 
    MAZE SCRIPT LIBRARY
    Export-WindowsDrivers.ps1
    ----------------------------------------
    Exports all installed drivers for reinstall recovery.
#>

Write-Host "=== DRIVER EXPORT TOOL ===" -ForegroundColor Cyan

$dest = Read-Host "Enter destination folder (example: E:\DriverBackup)"

if (-not (Test-Path $dest)) {
    Write-Host "Creating destination..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dest | Out-Null
}

Write-Host "Exporting drivers..." -ForegroundColor Yellow
Export-WindowsDriver -Online -Destination $dest

Write-Host "`n✔ Driver backup created." -ForegroundColor Green
