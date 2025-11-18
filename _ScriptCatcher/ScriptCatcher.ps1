function Register-ScriptRun {
    param([string])

     = "D:\Dev\script-hub\_ScriptCatcher"
     = "\ScriptLog.csv"

    if (!(Test-Path )) {
        "Date,Time,Script,Category" | Out-File  -Encoding UTF8
    }

     = switch -Regex () {
        "Windows"     { "Windows"; break }
        "Recovery"    { "Recovery"; break }
        "Docker"      { "Docker"; break }
        "Security"    { "Security"; break }
        "Network"     { "Network"; break }
        default       { "Unknown" }
    }

     = Get-Date -Format "yyyy-MM-dd"
     = Get-Date -Format "HH:mm:ss"
    ",,," | Out-File  -Append -Encoding UTF8

    if ( -ne "Unknown") {
         = "D:\Dev\script-hub\Scripts\"
        if (!(Test-Path )) { New-Item -Path  -ItemType Directory | Out-Null }
         = Split-Path  -Leaf
         = Join-Path  
        Move-Item   -Force
    }
}

function Show-ScriptSummary {
     = "D:\Dev\script-hub\_ScriptCatcher\ScriptLog.csv"
    if (!(Test-Path )) { Write-Host "No log file found."; return }
    Import-Csv  | Group-Object Category | Select-Object Name,Count | Format-Table -AutoSize
}
