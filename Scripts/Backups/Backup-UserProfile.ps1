<# 
    MAZE SCRIPT LIBRARY
    Backup-UserProfile.ps1
    ----------------------------------------
    Backs up key Windows user folders:
    Desktop, Documents, Downloads, Pictures, Music, Videos
#>

Write-Host "=== USER PROFILE BACKUP ===" -ForegroundColor Cyan

$src = "$env:USERPROFILE"
$dest = Read-Host "Enter backup destination (example: E:\Backups\UserProfile)"

if (-not (Test-Path $dest)) {
    Write-Host "Creating destination..." -ForegroundColor Yellow
    New-Item -Path $dest -ItemType Directory -Force | Out-Null
}

$folders = @("Desktop","Documents","Downloads","Pictures","Music","Videos")

foreach ($f in $folders) {
    $from = Join-Path $src $f
    $to   = Join-Path $dest $f

    Write-Host "Backing up $f..." -ForegroundColor Yellow
    Copy-Item $from -Destination $to -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n✔ User profile backup complete." -ForegroundColor Green
