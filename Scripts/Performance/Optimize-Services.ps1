Write-Host "=== OPTIMIZING WINDOWS SERVICES ===" -ForegroundColor Cyan

$disable = @(
    "Fax",
    "DiagTrack",
    "RetailDemo",
    "RemoteRegistry",
    "PrintNotify",
    "WSearch"
)

foreach ($svc in $disable) {
    try {
        Write-Host "Disabling $svc" -ForegroundColor Yellow
        Stop-Service $svc -Force -ErrorAction SilentlyContinue
        Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
    } catch {}
}

Write-Host "`n✔ Service optimization complete." -ForegroundColor Green
