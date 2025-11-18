param(
    [Parameter(Mandatory=$true)]
    [int]$DiskNumber,
    [ValidateSet("NTFS","FAT32")]
    [string]$FileSystem = "NTFS"
)

Write-Host "`n=== MAZE USB REBUILD STARTING ===`n" -ForegroundColor Cyan

# Unlock disk
Set-Disk -Number $DiskNumber -IsReadOnly $false -ErrorAction SilentlyContinue
Set-Disk -Number $DiskNumber -IsOffline $false -ErrorAction SilentlyContinue

Write-Host "Clearing disk $DiskNumber..." -ForegroundColor Yellow
Clear-Disk -Number $DiskNumber -RemoveData -Confirm:$false

Write-Host "Initializing disk as MBR..." -ForegroundColor Yellow
Initialize-Disk -Number $DiskNumber -PartitionStyle MBR

Write-Host "Creating new partition..." -ForegroundColor Yellow
$part = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -AssignDriveLetter

$dl = $part.DriveLetter
Write-Host "Formatting drive $dl as $FileSystem..." -ForegroundColor Yellow

Format-Volume -DriveLetter $dl -FileSystem $FileSystem -NewFileSystemLabel "USB" -Confirm:$false

Write-Host "`n=== MAZE USB REBUILD COMPLETE ===`n" -ForegroundColor Green
Get-Volume -DriveLetter $dl
