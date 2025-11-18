$root = "G:\Scripts"

Write-Host "`n=== MAZE TOOLBOX ===`n" -ForegroundColor Cyan

$categories = Get-ChildItem -Path $root -Directory

$items = @()
$index = 1

foreach ($cat in $categories) {
    $scripts = Get-ChildItem -Path $cat.FullName -Filter *.ps1 -File
    foreach ($script in $scripts) {
        $items += [PSCustomObject]@{
            Index      = $index
            Category   = $cat.Name
            Name       = $script.BaseName
            FullPath   = $script.FullName
        }
        $index++
    }
}

if (-not $items) {
    Write-Host "No scripts found under $root. Add some .ps1 files first." -ForegroundColor Yellow
    exit
}

foreach ($item in $items) {
    Write-Host ("[{0}] {1}\{2}" -f $item.Index, $item.Category, $item.Name) -ForegroundColor Green
}

$selection = Read-Host "`nSelect a script number to run (or press Enter to cancel)"

if (-not $selection) {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

$chosen = $items | Where-Object Index -eq [int]$selection

if (-not $chosen) {
    Write-Host "Invalid selection." -ForegroundColor Red
    exit
}

Write-Host "`nRunning: $($chosen.Category)\$($chosen.Name)`n" -ForegroundColor Cyan

# Special handling for known scripts that need parameters
switch -Wildcard ($chosen.Name) {
    "Rebuild-USB" {
        $disk = Read-Host "Enter DiskNumber (for example 3)"
        $fs   = Read-Host "FileSystem [NTFS/FAT32]"
        if (-not $fs) { $fs = "NTFS" }
        & $chosen.FullPath -DiskNumber [int]$disk -FileSystem $fs
    }
    default {
        # Generic: just invoke with no params
        & $chosen.FullPath
    }
}
