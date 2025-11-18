function Register-ScriptRun {
 function Register-ScriptRun {
    param(
        [string]$ScriptPath
    )

    $logFile = "G:\Scripts\_ScriptCatcher\ScriptLog.csv"

    # Ensure log file exists with headers
    if (!(Test-Path $logFile)) {
        "Date,Time,Script,Category" | Out-File $logFile -Encoding UTF8
    }

    # Auto-detect category based on folder name
    $category = switch -Regex ($ScriptPath) {
        "Recovery"    { "Recovery"; break }
        "Performance" { "Performance"; break }
        "DiskTools"   { "DiskTools"; break }
        "Network"     { "Network"; break }
        "Automation"  { "Automation"; break }
        "NAS"         { "NAS"; break }
        "Docker"      { "Docker"; break }
        "Security"    { "Security"; break }
        "Windows"     { "Windows"; break }
        default       { "Unknown" }
    }

    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"

    "$date,$time,$ScriptPath,$category" | Out-File $logFile -Append -Encoding UTF8
}

# Example: manually log a script run
# Register-ScriptRun -ScriptPath "G:\Scripts\Windows\ClearTemp.ps1"

