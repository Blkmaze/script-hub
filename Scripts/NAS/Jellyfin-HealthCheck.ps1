<# 
    MAZE SCRIPT LIBRARY
    Jellyfin-HealthCheck.ps1
    -------------------------------------
    Checks Jellyfin server health & API status.
#>

Write-Host "=== JELLYFIN HEALTH CHECK ===" -ForegroundColor Cyan

$server = Read-Host "Enter Jellyfin server URL (example: http://192.168.1.182:8096)"

try {
    $sys = Invoke-RestMethod "$server/System/Info"
    $sessions = Invoke-RestMethod "$server/Sessions"
}
catch {
    Write-Host "Cannot connect to Jellyfin server." -ForegroundColor Red
    exit
}

Write-Host "`n--- SERVER INFO ---" -ForegroundColor Yellow
Write-Host "Version: $($sys.Version)"
Write-Host "Server Name: $($sys.ServerName)"

Write-Host "`n--- ACTIVE SESSIONS ---" -ForegroundColor Yellow

if ($sessions.Count -eq 0) {
    Write-Host "No active sessions." -ForegroundColor DarkYellow
} else {
    foreach ($s in $sessions) {
        Write-Host "User: $($s.UserName)  Playing: $($s.NowPlayingItem.Name)"
    }
}

Write-Host "`n✔ Jellyfin health OK." -ForegroundColor Green
