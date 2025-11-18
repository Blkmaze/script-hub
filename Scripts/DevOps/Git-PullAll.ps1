<# 
    MAZE SCRIPT LIBRARY
    Git-PullAll.ps1
    ----------------------------------------
    Pulls the latest code for every Git repository
    inside a directory you choose.
#>

Write-Host "=== GIT PULL ALL ===" -ForegroundColor Cyan

$root = Read-Host "Enter folder containing repositories (example: D:\Dev)"

if (-not (Test-Path $root)) {
    Write-Host "Folder does not exist!" -ForegroundColor Red
    exit
}

$repos = Get-ChildItem $root -Recurse -Directory -Filter ".git" -ErrorAction SilentlyContinue

if ($repos.Count -eq 0) {
    Write-Host "No Git repositories found." -ForegroundColor DarkYellow
    exit
}

foreach ($repo in $repos) {
    $path = Split-Path $repo.FullName
    Write-Host "`nUpdating repo at $path" -ForegroundColor Yellow
    Push-Location $path
    git pull
    Pop-Location
}

Write-Host "`n✔ All repositories updated." -ForegroundColor Green
