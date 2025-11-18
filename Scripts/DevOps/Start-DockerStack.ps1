<# 
    MAZE SCRIPT LIBRARY
    Start-DockerStack.ps1
    ----------------------------------------
    Starts a Docker stack using docker-compose.
#>

Write-Host "=== START DOCKER STACK ===" -ForegroundColor Cyan

$path = Read-Host "Enter folder containing docker-compose.yml"

if (-not (Test-Path "$path\docker-compose.yml")) {
    Write-Host "docker-compose.yml not found!" -ForegroundColor Red
    exit
}

Write-Host "`nStarting stack..." -ForegroundColor Yellow
docker compose -f "$path\docker-compose.yml" up -d

Write-Host "`n✔ Stack started." -ForegroundColor Green
