 
Write-Host "=== CLEARING TEMP FILES ===" -ForegroundColor Cyan

$paths = @(
    "$env:TEMP\*",
    "$env:WINDIR\Temp\*"
)

foreach ($p in $paths) {

    Write-Host "`nChecking: $p" -ForegroundColor Yellow

    $files = Get-ChildItem $p -ErrorAction SilentlyContinue

    if ($files.Count -eq 0) {
        Write-Host "No files found to delete." -ForegroundColor DarkYellow
        continue
    }

    Write-Host "Deleting $($files.Count) items..." -ForegroundColor Cyan

    try {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Deleted successfully." -ForegroundColor Green
    }
    catch {
        Write-Host ("Error cleaning {0}: {1}" -f $p, ${_}) -ForegroundColor Red
    }

} # closes foreach

Write-Host "`nTemp cleanup complete." -ForegroundColor Green
