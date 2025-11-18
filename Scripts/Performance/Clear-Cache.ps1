Write-Host "=== CLEARING SYSTEM + BROWSER CACHE ===" -ForegroundColor Cyan

# Windows Temp
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Windows Store Cache
wsreset.exe -i

# DNS Cache
ipconfig /flushdns

# Edge Cache
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
Remove-Item $edge -Recurse -Force -ErrorAction SilentlyContinue

# Chrome Cache
$chrome = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*"
Remove-Item $chrome -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n✔ Cache cleared successfully." -ForegroundColor Green
