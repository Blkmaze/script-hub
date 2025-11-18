<# 
    MAZE SCRIPT LIBRARY
    Reset-NetworkStack.ps1
    ----------------------------------------
    Fully resets:
    • TCP/IP
    • Winsock
    • DNS Cache
    • Network adapters
#>

Write-Host "=== NETWORK STACK RESET ===" -ForegroundColor Cyan

Write-Host "Resetting Winsock..." -ForegroundColor Yellow
netsh winsock reset

Write-Host "Resetting TCP/IP..." -ForegroundColor Yellow
netsh int ip reset

Write-Host "Flushing DNS..." -ForegroundColor Yellow
ipconfig /flushdns

Write-Host "Releasing IP..." -ForegroundColor Yellow
ipconfig /release

Write-Host "Renewing IP..." -ForegroundColor Yellow
ipconfig /renew

Write-Host "`n✔ Network reset complete." -ForegroundColor Green
Write-Host "You should reboot for full effect." -ForegroundColor Magenta
