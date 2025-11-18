<# 
    MAZE SCRIPT LIBRARY
    Docker-Logs.ps1
    -------------------------
    Lets you pick a container and view logs.
#>

Write-Host "=== DOCKER LOG VIEWER ===" -ForegroundColor Cyan

$containers = docker ps --format "{{.Names}}"

if (-not $containers) {
    Write-Host "No running containers found." -ForegroundColor Red
    exit
}

Write-Host "`nSelect a container:`n" -ForegroundColor Yellow

$containers |
    ForEach-Object -Begin { $i = 1 } `
                   -Process {
                        Write-Host "$i. $_"
                        $i++
                    }

$choice = Read-Host "`nEnter number"

$index = [int]$choice - 1
$target = $containers[$index]

Write-Host "`nStreaming logs for $target..." -ForegroundColor Cyan

docker logs -f $target
