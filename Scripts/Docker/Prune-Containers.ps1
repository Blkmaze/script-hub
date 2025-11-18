<# 
    MAZE SCRIPT LIBRARY
    Prune-Containers.ps1
    -------------------------
    Safely cleans unused Docker items:
    • Stopped containers
    • Unused images
    • Unused networks
    • Dangling volumes
#>

Write-Host "=== DOCKER CLEANUP TOOL ===" -ForegroundColor Cyan

Write-Host "`nStopping unused containers..." -ForegroundColor Yellow
docker container prune -f

Write-Host "`nRemoving unused images..." -ForegroundColor Yellow
docker image prune -a -f

Write-Host "`nCleaning networks..." -ForegroundColor Yellow
docker network prune -f

Write-Host "`nCleaning volumes..." -ForegroundColor Yellow
docker volume prune -f

Write-Host "`n✔ Docker cleanup complete." -ForegroundColor Green
