<# 
    MAZE SCRIPT LIBRARY
    NAS-MountSMB.ps1
    ------------------------------------
    Mounts a NAS SMB share to a drive letter.
#>

Write-Host "=== NAS SMB MOUNT TOOL ===" -ForegroundColor Cyan

$share = Read-Host "Enter NAS path (example: \\192.168.1.182\Public)"
$drive = Read-Host "Enter drive letter to use (example: P)"

$username = Read-Host "NAS username"
$password = Read-Host "NAS password"

Write-Host "`nMounting NAS share..." -ForegroundColor Yellow

New-PSDrive -Name $drive -PSProvider FileSystem -Root $share -Persist -Credential (New-Object System.Management.Automation.PSCredential($username,(ConvertTo-SecureString $password -AsPlainText -Force))) | Out-Null

if (Test-Path "$drive:\") {
    Write-Host "`n✔ NAS mounted at $drive:\" -ForegroundColor Green
} else {
    Write-Host "`n✖ Failed to mount NAS share." -ForegroundColor Red
}
