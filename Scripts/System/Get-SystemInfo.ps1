<# 
    MAZE SCRIPT LIBRARY
    Get-SystemInfo.ps1
    ----------------------------------------
    Gathers OS, hardware, and device information.
#>

Write-Host "=== MAZE SYSTEM INFORMATION ===" -ForegroundColor Cyan

# OS
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "`nOS: $($os.Caption) (Build $($os.BuildNumber))"
Write-Host "Install Date: $([Management.ManagementDateTimeConverter]::ToDateTime($os.InstallDate))"

# CPU
$cpu = Get-CimInstance Win32_Processor
Write-Host "`nCPU: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)  Threads: $($cpu.NumberOfLogicalProcessors)"

# RAM
$mem = Get-CimInstance Win32_ComputerSystem
Write-Host "`nRAM: $([math]::Round($mem.TotalPhysicalMemory / 1GB,2)) GB"

# GPU
$gpus = Get-CimInstance Win32_VideoController
Write-Host "`nGPU(s):"
$gpus | ForEach-Object { Write-Host " - $($_.Name)" }

# Motherboard
$board = Get-CimInstance Win32_BaseBoard
Write-Host "`nMotherboard: $($board.Manufacturer) $($board.Product)"

# BIOS
$bios = Get-CimInstance Win32_BIOS
Write-Host "BIOS Version: $($bios.SMBIOSBIOSVersion)"

# Disks
Write-Host "`nDisks:"
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, HealthStatus | Format-Table

# Network
Write-Host "`nNetwork Adapters:"
Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed | Format-Table

Write-Host "`n✔ System info collected." -ForegroundColor Green
