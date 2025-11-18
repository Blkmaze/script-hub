<# 
    MAZE SCRIPT LIBRARY
    Rebuild-IconCache.ps1
    ----------------------------------------
    Rebuilds the Windows icon cache and thumbnail cache.
#>

Write-Host "=== REBUILDING ICON & THUMBNAIL CACHE ===" -ForegroundColor Cyan

Write-Host "`nStopping Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

# Delete icon cache files
$iconPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*",
    "$env:LOCALAPPDATA\IconCache.db"
)

foreach ($path in $iconPaths) {
    Write-Host "Removing $path" -ForegroundColor DarkYellow
    Remove-Item $path -Force -Recurse -ErrorAction SilentlyContinue
}

# Delete thumbnail cache
Write-Host "Removing thumbnail cache..." -ForegroundColor Yellow
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*" -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "`nStarting Explorer..." -ForegroundColor Yellow
Start-Process explorer.exe

Write-Host "`n✔ Icon cache rebuilt." -ForegroundColor Green
