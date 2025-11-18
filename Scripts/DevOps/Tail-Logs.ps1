<# 
    MAZE SCRIPT LIBRARY
    Tail-Logs.ps1
    ----------------------------------------
    Tails logs from:
    • A log file
    • A folder full of logs
#>

Write-Host "=== LOG TAIL TOOL ===" -ForegroundColor Cyan

$target = Read-Host "Enter log file OR folder"

if ((Test-Path $target) -eq $false) {
    Write-Host "Path not found." -ForegroundColor Red
    exit
}

if ((Get-Item $target).PSIsContainer) {
    Write-Host "`nTailing all logs in folder..." -ForegroundColor Yellow
    Get-ChildItem $target -Filter *.log | ForEach-Object {
        Write-Host "=== $_ ===" -ForegroundColor Cyan
        Get-Content $_ -Wait -Tail 20
    }
} else {
    Write-Host "`nTailing file..." -ForegroundColor Yellow
    Get-Content $target -Wait -Tail 20
}

Write-Host "`n✔ Log tail session ended." -ForegroundColor Green
