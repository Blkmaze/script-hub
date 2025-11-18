<# 
    MAZE SCRIPT LIBRARY
    Sync-Folders.ps1
    ----------------------------------------
    Syncs two folders:
    • One-way
    • Two-way
#>

Write-Host "=== FOLDER SYNC TOOL ===" -ForegroundColor Cyan

$src = Read-Host "Enter SOURCE folder"
$dst = Read-Host "Enter DESTINATION folder"

if (-not (Test-Path $src)) { Write-Host "Source missing!" -ForegroundColor Red; exit }
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst | Out-Null }

$mode = Read-Host "Choose sync mode: 1=One-way, 2=Two-way"

switch ($mode) {

    "1" {
        Write-Host "One-way syncing..." -ForegroundColor Yellow
        robocopy $src $dst /MIR
        Write-Host "✔ One-way sync complete." -ForegroundColor Green
    }

    "2" {
        Write-Host "Two-way syncing..." -ForegroundColor Yellow
        robocopy $src $dst /MIR
        robocopy $dst $src /MIR
        Write-Host "✔ Two-way sync complete." -ForegroundColor Green
    }

    default {
        Write-Host "Invalid selection." -ForegroundColor Red
    }
}
