<# 
    MAZE ScriptHub AutoSync
    Syncs USB ScriptHub with GitHub repo: blkmaze/script-hub
#>

$RepoPath   = "G:\ScriptHubRepo"
$ScriptsSrc = "G:\Scripts"
$LogFile    = "G:\Scripts\_ScriptCatcher\AutoSync.log"
$GitURL     = "https://github.com/blkmaze/script-hub.git"

Start-Transcript -Path $LogFile -Append

Write-Host "=== ScriptHub AutoSync ===" -ForegroundColor Cyan

# Clone repository if missing
if (!(Test-Path $RepoPath)) {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    git clone $GitURL $RepoPath
}

# Pull latest changes
Write-Host "Pulling latest changes..." -ForegroundColor Yellow
cd $RepoPath
git pull --no-edit

# Sync repo → USB Scripts
Write-Host "Syncing repository to USB..." -ForegroundColor Yellow
robocopy "$RepoPath\Scripts" $ScriptsSrc /E /XO /R:0 /W:0 | Out-Null

# Sync USB → repo
Write-Host "Syncing USB Scripts to repository..." -ForegroundColor Yellow
robocopy $ScriptsSrc "$RepoPath\Scripts" /E /XO /R:0 /W:0 | Out-Null

# Commit and push back to GitHub if needed
Write-Host "Checking for changes..." -ForegroundColor Yellow
git add .

$changes = git status --porcelain
if ($changes) {
    $msg = "AutoSync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m "$msg"
    git push
    Write-Host "Changes synced to GitHub." -ForegroundColor Green
} else {
    Write-Host "No changes to sync." -ForegroundColor DarkYellow
}

Stop-Transcript
