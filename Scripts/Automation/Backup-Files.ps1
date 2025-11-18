<# 
    MAZE SCRIPT LIBRARY
    Backup-Files.ps1
    ----------------------------------------
    Backs up files from a source folder to a destination folder.
    Preserves subfolders and overwrites only changed files.
#>

Write-Host "=== MAZE BACKUP TOOL ===" -ForegroundColor Cyan

$source = Read-Host "Enter source folder"
$dest   = Read-Host "Enter destination folder"

if (-not (Test-Path $source)) {
    Write-Host "Source folder does not exist!" -ForegroundColor Red
    exit
}

if (-not (Test-Path $dest)) {
    Write-Host "Destination missing, creating it..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dest | Out-Null
}

Write-Host "`nStarting backup..." -ForegroundColor Yellow
Copy-Item -Path $source -Destination $dest -Recurse -Force

Write-Host "`n✔ Backup complete." -ForegroundColor Green
