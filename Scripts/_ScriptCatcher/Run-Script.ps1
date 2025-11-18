param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath
)

# Load the catcher functions
. "G:\Scripts\_ScriptCatcher\ScriptCatcher.ps1"

# Run the script
Write-Host "=== Executing $ScriptPath ===" -ForegroundColor Cyan
& $ScriptPath

# Log and move it
Register-ScriptRun -ScriptPath $ScriptPath
