<# 
    MAZE SCRIPT LIBRARY
    Fix-BootConfig.ps1
    ----------------------------------------------------
    Repairs Windows boot components:
      • Rebuilds BCD
      • Restores EFI boot files
      • Fixes boot sector (BIOS/MBR systems)
      • Fixes EFI partition (UEFI systems)
      • Logs everything to FixBootConfig.log
#>

$Log = "G:\Scripts\Recovery\FixBootConfig.log"
Start-Transcript -Path $Log -Force

Write-Host "=== WINDOWS BOOT REPAIR TOOL ===" -ForegroundColor Cyan

Write-Host "`nDetecting boot mode..." -ForegroundColor Yellow
$firmware = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "PEFirmwareType").PEFirmwareType

if ($firmware -eq 2) {
    Write-Host "System is using: BIOS / MBR" -ForegroundColor Green
    $BootMode = "BIOS"
} elseif ($firmware -eq 3) {
    Write-Host "System is using: UEFI / GPT" -ForegroundColor Green
    $BootMode = "UEFI"
} else {
    Write-Host "Unable to determine boot mode. Exiting." -ForegroundColor Red
    Stop-Transcript
    exit
}

Write-Host "`n=== STEP 1: Rebuilding BCD Store ===" -ForegroundColor Cyan
bcdedit /export C:\BCD_Backup
attrib c:\boot\bcd -h -r -s 2>$null
del c:\boot\bcd 2>$null
bcdboot C:\Windows /l en-us

Write-Host "BCD rebuild complete." -ForegroundColor Green

if ($BootMode -eq "UEFI") {

    Write-Host "`n=== STEP 2: Fixing EFI Boot Files ===" -ForegroundColor Cyan

    # Find EFI System Partition automatically
    $ESP = (Get-Partition | Where-Object {$_.GptType -eq "{C12A7328-F81F-11D2-BA4B-00A0C93EC93B}"})
    if (-not $ESP) {
        Write-Host "EFI System Partition NOT found!" -ForegroundColor Red
    } else {
        $drive = (Get-Volume -Partition $ESP).DriveLetter
        Write-Host "EFI Partition found on: $drive`:" -ForegroundColor Green

        Write-Host "Re-applying boot files..." -ForegroundColor Yellow
        bcdboot C:\Windows /l en-us /s "$drive`:\" /f UEFI
    }

} elseif ($BootMode -eq "BIOS") {

    Write-Host "`n=== STEP 2: Fixing MBR Boot Sector ===" -ForegroundColor Cyan

    bootrec /fixmbr
    bootrec /fixboot
    bootrec /scanos
    bootrec /rebuildbcd
}

Write-Host "`n=== STEP 3: Verification ===" -ForegroundColor Cyan
bcdedit

Write-Host "`n✔ Boot repair complete." -ForegroundColor Green
Write-Host "A reboot is required." -ForegroundColor Magenta

Stop-Transcript
