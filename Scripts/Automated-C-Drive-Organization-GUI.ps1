#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GUI – Automated C: Drive Organization & Mini PC Swap Prep

.DESCRIPTION
    WinForms GUI wrapper around your C: drive move script.
    - Choose Drive or NAS
    - Configure destination
    - Optional toggles: AutoConfirm, SkipBrowser, SkipDocker, DryRun
    - Scan / plan phase
    - Run migration with logging and stats
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ----------------------------
# GLOBALS
# ----------------------------
$script:colors = @{
    Header   = "Cyan"
    Success  = "Green"
    Warning  = "Yellow"
    Error    = "Red"
    Info     = "White"
    Progress = "Magenta"
}

$script:stats = @{
    TotalFiles  = 0
    TotalSize   = 0
    MoveSuccess = 0
    MoveFailed  = 0
    Folders     = @()
}

$script:foldersToMove = @()
$script:destinationBase = $null
$script:destinationType = "Drive"
$script:destinationDrive = "H:"
$script:NASPath = ""
$script:AutoConfirm = $false
$script:SkipBrowser = $false
$script:SkipDocker = $false
$script:DryRun = $false
$script:logFile = $null

# Helper: write to on-screen log + host
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $pref = @{
        Info    = "[*]"
        Success = "[+]"
        Warning = "[!]"
        Error   = "[X]"
        Progress= "[>]"
        Header  = "[=]"
    }[$Level]

    $line = "$timestamp $pref $Message"

    # Write to host
    switch ($Level) {
        "Success" { Write-Host $line -ForegroundColor Green }
        "Warning" { Write-Host $line -ForegroundColor Yellow }
        "Error"   { Write-Host $line -ForegroundColor Red }
        "Progress"{ Write-Host $line -ForegroundColor Magenta }
        "Header"  { Write-Host $line -ForegroundColor Cyan }
        default   { Write-Host $line -ForegroundColor White }
    }

    # Write to GUI log if available
    if ($script:LogTextBox -and -not $script:LogTextBox.IsDisposed) {
        $script:LogTextBox.AppendText($line + [Environment]::NewLine)
        $script:LogTextBox.ScrollToCaret()
    }
}

function Get-FolderSize {
    param([string]$Path)
    try {
        $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size/1GB, 2)
    } catch {
        return 0
    }
}

function Get-FileCount {
    param([string]$Path)
    try {
        return (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    } catch {
        return 0
    }
}

function Test-PathExists {
    param([string]$Path)
    return (Test-Path $Path -ErrorAction SilentlyContinue)
}

function Move-FolderSafe {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$FolderName,
        [bool]$CreateSymlink = $true
    )

    Write-Log "Processing: $FolderName" "Info"
    Write-Log " Source: $Source" "Info"
    Write-Log " Dest:   $Destination" "Info"

    if (!(Test-PathExists $Source)) {
        Write-Log " Source not found - skipping" "Warning"
        return $false
    }

    Write-Log " Calculating size..." "Progress"
    $sizeGB = Get-FolderSize $Source
    $fileCount = Get-FileCount $Source

    Write-Log " Size: $sizeGB GB | Files: $fileCount" "Info"

    if ($sizeGB -eq 0) {
        Write-Log " Folder empty - skipping" "Warning"
        return $false
    }

    $script:stats.TotalFiles += $fileCount
    $script:stats.TotalSize += $sizeGB

    if ($script:DryRun) {
        Write-Log "[DRY RUN] Would copy to $Destination" "Progress"
        return $true
    }

    try {
        # Ensure destination directory exists
        if (!(Test-PathExists $Destination)) {
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }

        Write-Log " Copying files with robocopy..." "Progress"
        $robocopyArgs = @(
            $Source,
            $Destination,
            "/E",
            "/COPYALL",
            "/R:3",
            "/W:5",
            "/MT:8",
            "/NP",
            "/NFL",
            "/NDL",
            "/NJH",
            "/NJS"
        )

        $result = Start-Process -FilePath "robocopy.exe" -ArgumentList $robocopyArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "NUL"

        if ($result.ExitCode -le 7) {
            Write-Log " Copy completed" "Success"

            $destFiles = Get-FileCount $Destination
            if ($destFiles -eq $fileCount) {
                Write-Log " Verified file count: $destFiles" "Success"
            } else {
                Write-Log " File count mismatch: Src=$fileCount Dest=$destFiles" "Warning"
            }

            if ($CreateSymlink) {
                Write-Log " Creating symbolic link..." "Progress"
                $backupPath = "$Source.original"

                if (Test-PathExists $backupPath) {
                    Remove-Item $backupPath -Recurse -Force
                }

                Rename-Item -Path $Source -NewName "$Source.original" -Force
                New-Item -ItemType SymbolicLink -Path $Source -Target $Destination -Force | Out-Null

                Write-Log " Symlink created" "Success"
                Write-Log " Original backed up to: $backupPath" "Info"
            }

            $script:stats.MoveSuccess++
            $script:stats.Folders += $FolderName
            return $true
        } else {
            throw "Robocopy failed with exit code: $($result.ExitCode)"
        }
    } catch {
        Write-Log " ERROR: $($_.Exception.Message)" "Error"
        $script:stats.MoveFailed++
        return $false
    }
}

function Discover-FoldersToMove {
    $script:foldersToMove = @()
    $userName = $env:USERNAME

    Write-Log "PHASE 1: DISCOVERY & ANALYSIS" "Header"

    # Drives overview
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ne $null} | Select-Object Name,
        @{Name='Used(GB)';Expression={[math]::Round($_.Used/1GB,2)}},
        @{Name='Free(GB)';Expression={[math]::Round($_.Free/1GB,2)}},
        @{Name='Total(GB)';Expression={[math]::Round(($_.Used + $_.Free)/1GB,2)}},
        @{Name='% Free';Expression={[math]::Round(($_.Free/($_.Used + $_.Free))*100,1)}}

    foreach ($d in $drives) {
        Write-Log ("Drive {0}: Used={1}GB Free={2}GB Total={3}GB ({4}% Free)" -f $d.Name,$d.'Used(GB)',$d.'Free(GB)',$d.'Total(GB)',$d.'% Free') "Info"
    }

    # Destination base
    if ($script:destinationType -eq "Drive") {
        $destDriveLetter = $script:destinationDrive.TrimEnd(':')
        $destDrive = $drives | Where-Object { $_.Name -eq $destDriveLetter }
        if (-not $destDrive) {
            throw "Destination drive $($script:destinationDrive) not found!"
        }
        $script:destinationBase = $script:destinationDrive.TrimEnd('\')
        Write-Log "Destination: Drive $($script:destinationDrive) (Free: $($destDrive.'Free(GB)') GB)" "Success"
    } else {
        if (-not (Test-PathExists $script:NASPath)) {
            throw "Cannot access NAS path: $($script:NASPath)"
        }
        $script:destinationBase = $script:NASPath.TrimEnd('\')
        Write-Log "Destination: NAS $($script:NASPath)" "Success"
    }

    Write-Log "PHASE 2: IDENTIFYING FOLDERS TO MOVE" "Header"

    # 1. GitHub / repos
    $githubPaths = @(
        "C:\Users\$userName\Documents\GitHub",
        "C:\Users\$userName\source\repos",
        "C:\Users\$userName\repos",
        "C:\Development",
        "C:\Projects",
        "C:\GitHub"
    )

    foreach ($path in $githubPaths) {
        if (Test-PathExists $path) {
            $script:foldersToMove += @{
                Name         = "GitHub-Repos"
                Source       = $path
                Destination  = "$($script:destinationBase)\GitHub-Repos"
                Priority     = 1
                CreateSymlink= $true
            }
            Write-Log "Found GitHub repos at $path" "Success"
            break
        }
    }

    # 2. Docker configs
    if (-not $script:SkipDocker) {
        $dockerPaths = @(
            "C:\ProgramData\Docker",
            "C:\Users\$userName\.docker",
            "C:\docker"
        )
        foreach ($path in $dockerPaths) {
            if (Test-PathExists $path) {
                $script:foldersToMove += @{
                    Name         = "Docker-Configs"
                    Source       = $path
                    Destination  = "$($script:destinationBase)\Docker-Configs"
                    Priority     = 1
                    CreateSymlink= $true
                }
                Write-Log "Found Docker configs at $path" "Success"
            }
        }
    }

    # 3. Scripts
    $scriptPaths = @(
        "C:\Scripts",
        "C:\Users\$userName\Scripts"
    )
    foreach ($path in $scriptPaths) {
        if (Test-PathExists $path) {
            $script:foldersToMove += @{
                Name         = "Scripts"
                Source       = $path
                Destination  = "$($script:destinationBase)\Scripts"
                Priority     = 2
                CreateSymlink= $true
            }
            Write-Log "Found Scripts at $path" "Success"
        }
    }

    # 4. Browser data
    if (-not $script:SkipBrowser) {
        $browserPaths = @(
            @{Name="Chrome"; Path="$env:LOCALAPPDATA\Google\Chrome\User Data"},
            @{Name="Edge";   Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data"}
        )
        foreach ($browser in $browserPaths) {
            if (Test-PathExists $browser.Path) {
                $script:foldersToMove += @{
                    Name         = "Browser-$($browser.Name)"
                    Source       = $browser.Path
                    Destination  = "$($script:destinationBase)\Backups\Browser-$($browser.Name)"
                    Priority     = 2
                    CreateSymlink= $false
                }
                Write-Log "Found $($browser.Name) data at $($browser.Path)" "Success"
            }
        }
    }

    # 5. SSH + configs bundle
    $configPaths = @(
        "C:\Users\$userName\.ssh",
        "C:\Users\$userName\.gitconfig"
    )
    $hasConfigs = $configPaths | Where-Object { Test-PathExists $_ }
    if ($hasConfigs) {
        $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $tempBundle = "C:\Temp\Config-Bundle-$timestamp"
        New-Item -ItemType Directory -Path $tempBundle -Force | Out-Null

        foreach ($path in $configPaths) {
            if (Test-PathExists $path) {
                $itemName = Split-Path $path -Leaf
                Copy-Item $path -Destination "$tempBundle\$itemName" -Recurse -Force
                Write-Log "Added to config bundle: $itemName" "Success"
            }
        }
        if (Test-PathExists $PROFILE) {
            Copy-Item $PROFILE -Destination "$tempBundle\PowerShell-Profile.ps1" -Force
            Write-Log "Added PowerShell profile to config bundle" "Success"
        }

        $script:foldersToMove += @{
            Name         = "SSH-and-Configs"
            Source       = $tempBundle
            Destination  = "$($script:destinationBase)\Backups\Configs"
            Priority     = 2
            CreateSymlink= $false
        }
    }

    # 6. Development folders
    $devPaths = @(
        "C:\Users\$userName\source",
        "C:\Users\$userName\projects"
    )
    foreach ($path in $devPaths) {
        if (Test-PathExists $path) {
            $folderName = Split-Path $path -Leaf
            $script:foldersToMove += @{
                Name         = "Dev-$folderName"
                Source       = $path
                Destination  = "$($script:destinationBase)\Development\$folderName"
                Priority     = 1
                CreateSymlink= $true
            }
            Write-Log "Found development folder at $path" "Success"
        }
    }

    if ($script:foldersToMove.Count -eq 0) {
        Write-Log "No folders found to move. Either everything is already moved or paths don't exist." "Warning"
    } else {
        Write-Log "Found $($script:foldersToMove.Count) folder(s) to move." "Info"
    }
}

function Show-Plan {
    if ($script:foldersToMove.Count -eq 0) {
        Write-Log "Nothing planned yet. Run 'Scan / Plan' first." "Warning"
        return
    }

    Write-Log "PHASE 3: PLAN SUMMARY" "Header"

    foreach ($folder in ($script:foldersToMove | Sort-Object Priority)) {
        $size = Get-FolderSize $folder.Source
        $files = Get-FileCount $folder.Source
        Write-Log "[$($folder.Priority)] $($folder.Name)" "Info"
        Write-Log " From: $($folder.Source)" "Info"
        Write-Log " To:   $($folder.Destination)" "Info"
        Write-Log " Size: $size GB | Files: $files | Symlink: $($folder.CreateSymlink)" "Info"
    }

    if ($script:DryRun) {
        Write-Log "DRY RUN mode is ON – no files will be moved when you click 'Run Migration'." "Progress"
    }
}

function Run-Migration {
    if ($script:foldersToMove.Count -eq 0) {
        Write-Log "No folders queued. Run Scan / Plan first." "Warning"
        return
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $script:logFile = "C:\CDrive_Organization_Log_$timestamp.txt"
    Start-Transcript -Path $script:logFile | Out-Null
    Write-Log "Transcript started: $($script:logFile)" "Info"

    $script:stats.TotalFiles = 0
    $script:stats.TotalSize = 0
    $script:stats.MoveSuccess = 0
    $script:stats.MoveFailed = 0
    $script:stats.Folders = @()

    Write-Log "PHASE 4: MIGRATION" "Header"

    $startTime = Get-Date
    $sortedFolders = $script:foldersToMove | Sort-Object Priority

    foreach ($folder in $sortedFolders) {
        Move-FolderSafe -Source $folder.Source -Destination $folder.Destination `
            -FolderName $folder.Name -CreateSymlink $folder.CreateSymlink | Out-Null
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Log "PHASE 5: VERIFICATION" "Header"
    foreach ($folder in $sortedFolders) {
        if (Test-PathExists $folder.Destination) {
            $destSize = Get-FolderSize $folder.Destination
            Write-Log "$($folder.Name): $destSize GB at $($folder.Destination)" "Success"
        } else {
            Write-Log "$($folder.Name): DESTINATION MISSING!" "Error"
        }
    }

    Write-Log "PHASE 6: FINAL REPORT" "Header"
    Write-Log ("Duration: {0}" -f $duration.ToString("hh\:mm\:ss")) "Info"
    Write-Log ("Total Files Processed: {0}" -f $script:stats.TotalFiles) "Info"
    Write-Log ("Total Size Moved: {0} GB" -f [math]::Round($script:stats.TotalSize,2)) "Info"
    Write-Log ("Successful Moves: {0}" -f $script:stats.MoveSuccess) "Success"
    Write-Log ("Failed Moves: {0}" -f $script:stats.MoveFailed) `
        ($(if($script:stats.MoveFailed -gt 0){"Error"}else{"Success"}))

    $cDrive = Get-PSDrive C
    Write-Log ("C: Used={0}GB Free={1}GB Total={2}GB" -f `
        [math]::Round($cDrive.Used/1GB,2), `
        [math]::Round($cDrive.Free/1GB,2), `
        [math]::Round(($cDrive.Used + $cDrive.Free)/1GB,2)) "Info"

    if ($script:destinationType -eq "Drive") {
        $destDrive = Get-PSDrive ($script:destinationDrive.TrimEnd(':'))
        Write-Log ("{0} Used={1}GB Free={2}GB" -f `
            $script:destinationDrive, `
            [math]::Round($destDrive.Used/1GB,2), `
            [math]::Round($destDrive.Free/1GB,2)) "Info"
    }

    Stop-Transcript | Out-Null
    Write-Log "Transcript saved: $($script:logFile)" "Info"
    Write-Log "All done. Ready for mini PC swap once validated." "Success"
}

# ----------------------------
# BUILD GUI
# ----------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Maze – C: Drive Organization GUI"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.StartPosition = "CenterScreen"

# Destination type
$rbDrive = New-Object System.Windows.Forms.RadioButton
$rbDrive.Text = "Destination: Drive"
$rbDrive.Location = New-Object System.Drawing.Point(20,20)
$rbDrive.Checked = $true

$rbNAS = New-Object System.Windows.Forms.RadioButton
$rbNAS.Text = "Destination: NAS"
$rbNAS.Location = New-Object System.Drawing.Point(20,45)

# Drive textbox
$lblDrive = New-Object System.Windows.Forms.Label
$lblDrive.Text = "Drive Letter (e.g. H:)"
$lblDrive.Location = New-Object System.Drawing.Point(200, 22)
$lblDrive.AutoSize = $true

$txtDrive = New-Object System.Windows.Forms.TextBox
$txtDrive.Location = New-Object System.Drawing.Point(340, 18)
$txtDrive.Size = New-Object System.Drawing.Size(80, 20)
$txtDrive.Text = "H:"

# NAS path
$lblNAS = New-Object System.Windows.Forms.Label
$lblNAS.Text = "NAS Path (UNC):"
$lblNAS.Location = New-Object System.Drawing.Point(200, 48)
$lblNAS.AutoSize = $true

$txtNAS = New-Object System.Windows.Forms.TextBox
$txtNAS.Location = New-Object System.Drawing.Point(340, 45)
$txtNAS.Size = New-Object System.Drawing.Size(250, 20)
$txtNAS.Text = "\\192.168.1.100\Backup"

# Checkboxes
$chkAutoConfirm = New-Object System.Windows.Forms.CheckBox
$chkAutoConfirm.Text = "AutoConfirm (skip prompt)"
$chkAutoConfirm.Location = New-Object System.Drawing.Point(20, 80)
$chkAutoConfirm.AutoSize = $true

$chkSkipBrowser = New-Object System.Windows.Forms.CheckBox
$chkSkipBrowser.Text = "Skip Browser Data"
$chkSkipBrowser.Location = New-Object System.Drawing.Point(220, 80)
$chkSkipBrowser.AutoSize = $true

$chkSkipDocker = New-Object System.Windows.Forms.CheckBox
$chkSkipDocker.Text = "Skip Docker Configs"
$chkSkipDocker.Location = New-Object System.Drawing.Point(390, 80)
$chkSkipDocker.AutoSize = $true

$chkDryRun = New-Object System.Windows.Forms.CheckBox
$chkDryRun.Text = "Dry Run (no changes)"
$chkDryRun.Location = New-Object System.Drawing.Point(580, 80)
$chkDryRun.AutoSize = $true

# Buttons
$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = "1. Scan / Plan"
$btnScan.Location = New-Object System.Drawing.Point(20, 115)
$btnScan.Size = New-Object System.Drawing.Size(120, 30)

$btnShowPlan = New-Object System.Windows.Forms.Button
$btnShowPlan.Text = "2. Show Plan Summary"
$btnShowPlan.Location = New-Object System.Drawing.Point(160, 115)
$btnShowPlan.Size = New-Object System.Drawing.Size(160, 30)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "3. Run Migration"
$btnRun.Location = New-Object System.Drawing.Point(340, 115)
$btnRun.Size = New-Object System.Drawing.Size(140, 30)

# Log TextBox
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = New-Object System.Drawing.Point(20, 160)
$logBox.Size = New-Object System.Drawing.Size(840, 430)
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)

$script:LogTextBox = $logBox

# Wire up events
$rbDrive.Add_CheckedChanged({
    if ($rbDrive.Checked) {
        $script:destinationType = "Drive"
    }
})

$rbNAS.Add_CheckedChanged({
    if ($rbNAS.Checked) {
        $script:destinationType = "NAS"
    }
})

$btnScan.Add_Click({
    try {
        # Read settings from controls
        $script:destinationDrive = $txtDrive.Text.Trim()
        $script:NASPath = $txtNAS.Text.Trim()
        $script:AutoConfirm = $chkAutoConfirm.Checked
        $script:SkipBrowser = $chkSkipBrowser.Checked
        $script:SkipDocker = $chkSkipDocker.Checked
        $script:DryRun = $chkDryRun.Checked

        $logBox.Clear()
        Write-Log "Starting Scan / Plan phase..." "Header"
        Discover-FoldersToMove
        Show-Plan
    } catch {
        Write-Log "Scan error: $($_.Exception.Message)" "Error"
    }
})

$btnShowPlan.Add_Click({
    try {
        Show-Plan
    } catch {
        Write-Log "Show Plan error: $($_.Exception.Message)" "Error"
    }
})

$btnRun.Add_Click({
    try {
        if (-not $script:AutoConfirm -and -not $script:DryRun) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "This will MOVE data and create symlinks. Continue?",
                "Confirm Migration",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Log "Migration cancelled by user." "Warning"
                return
            }
        }
        Run-Migration
    } catch {
        Write-Log "Migration error: $($_.Exception.Message)" "Error"
    }
})

# Add controls
$form.Controls.Add($rbDrive)
$form.Controls.Add($rbNAS)
$form.Controls.Add($lblDrive)
$form.Controls.Add($txtDrive)
$form.Controls.Add($lblNAS)
$form.Controls.Add($txtNAS)
$form.Controls.Add($chkAutoConfirm)
$form.Controls.Add($chkSkipBrowser)
$form.Controls.Add($chkSkipDocker)
$form.Controls.Add($chkDryRun)
$form.Controls.Add($btnScan)
$form.Controls.Add($btnShowPlan)
$form.Controls.Add($btnRun)
$form.Controls.Add($logBox)

[System.Windows.Forms.Application]::EnableVisualStyles()
$form.Topmost = $true
$form.Add_Shown({ $form.Activate(); Write-Log "Maze – C: Drive Organization GUI ready." "Header" })
[System.Windows.Forms.Application]::Run($form)
