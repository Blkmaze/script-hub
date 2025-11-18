function Register-ScriptRun {
    param([string]$ScriptPath)

    $logRoot = "D:\Dev\script-hub\_ScriptCatcher"
    $logFile = "$logRoot\ScriptLog.csv"

    if (!(Test-Path $logFile)) {
        "Date,Time,Script,Category" | Out-File $logFile -Encoding UTF8
    }

    $category = switch -Regex ($ScriptPath) {
        "Windows"     { "Windows"; break }
        "Recovery"    { "Recovery"; break }
        "Docker"      { "Docker"; break }
        "Security"    { "Security"; break }
        "Network"     { "Network"; break }
        default       { "Unknown" }
    }

    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"
    "$date,$time,$ScriptPath,$category" | Out-File $logFile -Append -Encoding UTF8

    if ($category -ne "Unknown") {
        $destFolder = "D:\Dev\script-hub\Scripts\$category"
        if (!(Test-Path $destFolder)) { 
            New-Item -Path $destFolder -ItemType Directory | Out-Null 
        }
        $fileName = Split-Path $ScriptPath -Leaf
        $destPath = Join-Path $destFolder $fileName
        Move-Item $ScriptPath $destPath -Force
    }
}

function Show-ScriptSummary {
    $logFile = "D:\Dev\script-hub\_ScriptCatcher\ScriptLog.csv"
    if (!(Test-Path $logFile)) { Write-Host "No log file found."; return }
    Import-Csv $logFile | Group-Object Category | Select-Object Name,Count | Format-Table -AutoSize
}
