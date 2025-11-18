<# 
    MAZE SCRIPT LIBRARY
    SystemRestore.ps1
    ----------------------------------------
    • Creates a restore point
    • Lists existing restore points
    • Restores a selected point
#>

Write-Host "=== SYSTEM RESTORE TOOL ===" -ForegroundColor Cyan

Write-Host "1) Create Restore Point"
Write-Host "2) List Restore Points"
Write-Host "3) Restore a Restore Point"

$choice = Read-Host "Choose an option"

switch ($choice) {

    "1" {
        $name = Read-Host "Enter restore point name"
        Write-Host "Creating restore point..." -ForegroundColor Yellow

        Checkpoint-Computer -Description $name -RestorePointType "MODIFY_SETTINGS"

        Write-Host "✔ Restore point created." -ForegroundColor Green
    }

    "2" {
        Write-Host "Available Restore Points:" -ForegroundColor Yellow
        Get-ComputerRestorePoint | Format-Table -AutoSize
    }

    "3" {
        $rp = Read-Host "Enter sequence number of restore point to restore"
        Write-Host "Restoring... (system will reboot)" -ForegroundColor Yellow

        Restore-Computer -RestorePoint $rp
    }

    default {
        Write-Host "Invalid selection." -ForegroundColor Red
    }
}
