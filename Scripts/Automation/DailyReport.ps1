<# 
    MAZE SCRIPT LIBRARY
    DailyReport.ps1
    ----------------------------------------
    Generates a daily report including:
    • System uptime
    • Disk usage
    • CPU load
    • RAM status
    • Network info
    • Running critical services
#>

Write-Host "=== MAZE DAILY REPORT ===" -ForegroundColor Cyan

# Uptime
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Host "`nSystem Uptime: $([math]::Round($uptime.TotalHours,2)) hours" -ForegroundColor Yellow

# CPU
$cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
Write-Host "CPU Load: $([math]::Round($cpuLoad,2))%" 

# RAM
$mem = Get-CimInstance Win32_OperatingSystem
$free = [math]::Round($mem.FreePhysicalMemory/1MB,2)
$total = [math]::Round($mem.TotalVisibleMemorySize/1MB,2)
Write-Host "RAM: $free GB free / $total GB total"

# DISKS
Write-Host "`nDisks:" -ForegroundColor Yellow
Get-PSDrive -PSProvider FileSystem | Format-Table Name, Used, Free, Root

# Network
$adapter = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1
Write-Host "`nNetwork Adapter:"
Write-Host "IP: $($adapter.IPAddress)"
Write-Host "Prefix: $($adapter.PrefixLength)"

# Services to monitor
$services = "WinDefend", "BITS", "WSearch"
Write-Host "`nCritical Services:" -ForegroundColor Yellow
Get-Service $services | Format-Table Name, Status

Write-Host "`n✔ Daily report complete." -ForegroundColor Green
