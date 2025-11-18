<# 
    MAZE SCRIPT LIBRARY
    Repair-Windows.ps1
    ----------------------------------------
    Runs SFC + DISM automatically
    Fixes component store
#>

Write-Host "=== WINDOWS REPAIR TOOL ===" -ForegroundColor Cyan

Write-Host "`nRunning SFC..." -ForegroundColor Yellow
sfc /scannow

Write-Host "`nRunning DISM CheckHealth..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /CheckHealth

Write-Host "`nRunning DISM ScanHealth..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /ScanHealth

Write-Host "`nRunning DISM RestoreHealth..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /RestoreHealth

Write-Host "`n✔ Windows repair process complete." -ForegroundColor Green
