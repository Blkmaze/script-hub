<# 
    MAZE SCRIPT LIBRARY
    SystemCleanup.ps1
    ----------------------------------------
    Performs a safe system cleanup including:
    • Temp files
    • Log files
    • SoftwareDistribution downloads
    • Browser caches (Edge/Chrome)
#>

Write-Host "=== MAZE SYSTEM CLEANUP ===" -ForegroundColor Cyan

# Temp
Write-Host "`nClearing user temp..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "Clearing Windows temp..." -ForegroundColor Yellow
Remove-Item "$env:WINDIR\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue

# Windows Update cache
Write-Host "`nCleaning Windows Update downloads..." -ForegroundColor Yellow
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -ErrorAction SilentlyContinue

# Logs
Write-Host "`nClearing log files..." -ForegroundColor Yellow
Remove-Item "C:\Windows\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue

# Browser cache
Write-Host "`nClearing Edge/Chrome caches..." -ForegroundColor Yellow
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "`n✔ System cleanup complete." -ForegroundColor Green
