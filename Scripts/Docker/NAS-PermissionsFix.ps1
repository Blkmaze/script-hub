<# 
    MAZE SCRIPT LIBRARY
    NAS-PermissionsFix.ps1
    --------------------------------------
    Fixes SMB share permission issues on Windows.
    • Clears saved credentials
    • Reconnects with correct user/pass
    • Resets local NTFS ACL permissions
#>

Write-Host "=== NAS PERMISSIONS FIX ===" -ForegroundColor Cyan

$share = Read-Host "Enter NAS share path (example: \\192.168.1.182\Public)"

Write-Host "`nClearing old credentials..." -ForegroundColor Yellow
cmdkey /delete:$share 2>$null

$username = Read-Host "NAS username"
$password = Read-Host "NAS password"

Write-Host "`nConnecting to NAS share..." -ForegroundColor Yellow
New-PSDrive -Name Z -PSProvider FileSystem -Root $share -Persist -Credential (New-Object PSCredential($username,(ConvertTo-SecureString $password -AsPlainText -Force))) | Out-Null

if (Test-Path "Z:\") {
    Write-Host "Connected." -ForegroundColor Green
} else {
    Write-Host "Failed to connect." -ForegroundColor Red
    exit
}

Write-Host "Fixing permissions on Z:\" -ForegroundColor Yellow
icacls "Z:\" /grant "$env:USERNAME:(OI)(CI)F" /T

Write-Host "`n✔ NAS permissions repaired." -ForegroundColor Green
