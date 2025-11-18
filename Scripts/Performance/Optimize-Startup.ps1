Write-Host "=== OPTIMIZING STARTUP PROGRAMS ===" -ForegroundColor Cyan

# Disable startup apps except known essentials
$keep = @(
    "Windows Security notification icon",
    "OneDrive",
    "Microsoft Teams",
    "SecurityHealth",
    "WindowsDefender"
)

$startup = Get-CimInstance Win32_StartupCommand

foreach ($item in $startup) {
    if ($keep -notcontains $item.Name) {
        Write-Host "Disabling: $($item.Name)" -ForegroundColor Yellow
        try {
            Disable-ScheduledTask -TaskName $item.Name -ErrorAction SilentlyContinue
        } catch {}
    } else {
        Write-Host "Keeping: $($item.Name)" -ForegroundColor Green
    }
}

Write-Host "`n✔ Startup optimization complete." -ForegroundColor Green
