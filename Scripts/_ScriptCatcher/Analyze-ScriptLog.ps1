$logFile = "G:\Scripts\_ScriptCatcher\ScriptLog.csv"

if (!(Test-Path $logFile)) {
    Write-Host "No log file found at $logFile" -ForegroundColor Red
    exit
}

Write-Host "=== Top Scripts Used ===" -ForegroundColor Cyan
Import-Csv $logFile |
    Group-Object Script |
    Sort-Object Count -Descending |
    Select-Object Name, Count

Write-Host "`n=== Usage by Category ===" -ForegroundColor Cyan
Import-Csv $logFile |
    Group-Object Category |
    Sort-Object Count -Descending |
    Select-Object Name, Count
