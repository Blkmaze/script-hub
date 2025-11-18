<# 
    MAZE SCRIPT LIBRARY
    Docker-Status.ps1
    -------------------------
    Shows Docker health:
    • Running containers
    • All containers
    • Images
    • Volumes
    • Networks
#>

Write-Host "=== DOCKER SYSTEM STATUS ===" -ForegroundColor Cyan

Write-Host "`n--- RUNNING CONTAINERS ---" -ForegroundColor Yellow
docker ps

Write-Host "`n--- ALL CONTAINERS ---" -ForegroundColor Yellow
docker ps -a

Write-Host "`n--- IMAGES ---" -ForegroundColor Yellow
docker images

Write-Host "`n--- VOLUMES ---" -ForegroundColor Yellow
docker volume ls

Write-Host "`n--- NETWORKS ---" -ForegroundColor Yellow
docker network ls

Write-Host "`n✔ Docker status complete." -ForegroundColor Green
