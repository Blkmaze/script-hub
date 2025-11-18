<# 
    MAZE SCRIPT LIBRARY
    Check-EventLogs.ps1
    ----------------------------------------
    Shows critical and error-level events from the last 48 hours.
#>

Write-Host "=== EVENT LOG CHECK ===" -ForegroundColor Cyan

$errors = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Level   = 1,2,3   # Critical, Error, Warning
    StartTime = (Get-Date).AddHours(-48)
} -ErrorAction SilentlyContinue

if ($errors.Count -eq 0) {
    Write-Host "No critical or error events found." -ForegroundColor Green
    exit
}

Write-Host "`nRecent system errors/warnings:" -ForegroundColor Yellow

$errors | Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-List

Write-Host "`n✔ Event scan complete." -ForegroundColor Green
