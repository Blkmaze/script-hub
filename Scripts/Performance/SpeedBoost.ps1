Write-Host "=== MAZE SPEED BOOST ACTIVATED ===" -ForegroundColor Cyan

# Flush memory standby list (RAM boost)
Write-Host "Clearing standby memory..." -ForegroundColor Yellow
rammap.exe -Ew -StandbyList 2>$null

# Clear prefetch
Write-Host "Clearing Prefetch..." -ForegroundColor Yellow
Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

# Reset network stack
Write-Host "Refreshing network stack..." -ForegroundColor Yellow
ipconfig /flushdns
ipconfig /release
ipconfig /renew
netsh int ip reset

# Optimize system files
Write-Host "Running system file optimizer..." -ForegroundColor Yellow
dism /online /cleanup-image /startcomponentcleanup

Write-Host "`n✔ Performance boost complete." -ForegroundColor Green
